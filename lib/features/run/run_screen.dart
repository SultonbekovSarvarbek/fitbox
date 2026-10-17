import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../progress/data/progress_models.dart';
import '../setup/setup_profile.dart';
import 'run_tracker.dart';
import 'widgets/route_sketch.dart';

enum _Phase { setup, countdown, active, done }

enum _Gps { checking, off, denied, searching, ready }

extension RunActivityL10n on RunActivity {
  String label(BuildContext context) => switch (this) {
    RunActivity.run => context.l10n.activityRun,
    RunActivity.walk => context.l10n.activityWalk,
    RunActivity.bike => context.l10n.activityBike,
  };

  IconData get icon => switch (this) {
    RunActivity.run => Icons.directions_run_rounded,
    RunActivity.walk => Icons.directions_walk_rounded,
    RunActivity.bike => Icons.directions_bike_rounded,
  };
}

/// Yugurish rejimi: GPS → masofa, temp, real vaqtda kaloriya (MET × vazn × vaqt).
class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen>
    with TickerProviderStateMixin {
  var _phase = _Phase.setup;
  var _gps = _Gps.checking;
  double? _accuracy;
  var _activity = RunActivity.run;
  RunSession? _session;
  bool _paused = false;
  int _countdown = 3;

  StreamSubscription<Position>? _positions;

  Timer? _ticker;

  /// Jonli puls (yo'l boshi, START halqalari).
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  /// STOP — bosib turish (tasodifan to'xtatmaslik uchun).
  late final _hold =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finish();
      });

  StreamSubscription<ServiceStatus>? _service;

  @override
  void initState() {
    super.initState();
    _initGps();
    // Joylashuv yoqilsa/o'chirilsa — darhol qayta tekshiramiz.
    _service = Geolocator.getServiceStatusStream().listen((s) {
      if (!mounted) return;
      if (s == ServiceStatus.disabled) {
        setState(() => _gps = _Gps.off);
      } else if (_phase == _Phase.setup) {
        _positions?.cancel();
        setState(() => _gps = _Gps.checking);
        _initGps();
      }
    });
  }

  @override
  void dispose() {
    _positions?.cancel();
    _service?.cancel();
    _ticker?.cancel();
    _pulse.dispose();
    _hold.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  // ---------------------------------------------------------------- GPS

  Future<void> _initGps() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _gps = _Gps.off);
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _gps = _Gps.denied);
      return;
    }
    if (!mounted) return;
    setState(() => _gps = _Gps.searching);
    _positions = Geolocator.getPositionStream(locationSettings: _settings())
        .listen(
          _onPosition,
          onError: (Object e) {
            debugPrint('Run GPS: $e');
            if (mounted && e is LocationServiceDisabledException) {
              setState(() => _gps = _Gps.off);
            }
          },
        );
  }

  LocationSettings _settings() {
    final l10n = context.l10n;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return AndroidSettings(
      accuracy: LocationAccuracy.best,
      intervalDuration: const Duration(seconds: 1),
      // Ekran o'chsa ham kuzatuv davom etadi (bildirishnoma bilan).
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: l10n.runNotificationTitle,
        notificationText: l10n.runNotificationText,
        enableWakeLock: true,
      ),
    );
  }

  void _onPosition(Position p) {
    if (!mounted) return;
    if (_phase == _Phase.setup || _phase == _Phase.countdown) {
      setState(() {
        _accuracy = p.accuracy;
        _gps = p.accuracy <= 30 ? _Gps.ready : _Gps.searching;
      });
      return;
    }
    if (_phase != _Phase.active || _paused) return;
    final km = _session!.addPoint(
      GeoPoint(p.latitude, p.longitude, p.timestamp, accuracy: p.accuracy),
    );
    setState(() => _accuracy = p.accuracy);
    if (km != null) _announceKm(km);
  }

  // ---------------------------------------------------------------- Oqim

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = _Phase.countdown;
      _countdown = 3;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_countdown <= 1) {
        t.cancel();
        _begin();
      } else {
        setState(() => _countdown--);
        HapticFeedback.selectionClick();
      }
    });
  }

  void _begin() {
    final weight = ref.read(userProvider).weightKg.toDouble();
    setState(() {
      _session = RunSession(activity: _activity, weightKg: weight);
      _phase = _Phase.active;
      _paused = false;
    });
    WakelockPlus.enable();
    HapticFeedback.heavyImpact();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_phase == _Phase.active && !_paused) {
        setState(() => _session!.tick(const Duration(seconds: 1)));
      }
    });
  }

  void _togglePause() {
    HapticFeedback.mediumImpact();
    setState(() => _paused = !_paused);
  }

  void _finish() {
    _ticker?.cancel();
    _positions?.cancel();
    WakelockPlus.disable();
    HapticFeedback.heavyImpact();
    setState(() => _phase = _Phase.done);
  }

  void _save() {
    final s = _session!;
    final l10n = context.l10n;
    ref
        .read(workoutLogProvider.notifier)
        .add(
          LogEntry(
            date: DateTime.now(),
            title: l10n.runLogTitle(
              _activity.label(context),
              (s.distanceM / 1000).toStringAsFixed(2),
            ),
            minutes: (s.active.inSeconds / 60).ceil(),
            kcal: s.kcal.round(),
            activity: _activity.name,
            distanceKm: double.parse((s.distanceM / 1000).toStringAsFixed(2)),
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.saved)));
    context.pop();
  }

  /// Har to'liq kilometr — kuchli titrash (yugurishda ovoz kerak emas).
  void _announceKm(int km) => HapticFeedback.heavyImpact();

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Faol mashg'ulotni orqaga tugmasi bilan tasodifan yopib bo'lmaydi.
      canPop: _phase != _Phase.active && _phase != _Phase.countdown,
      child: switch (_phase) {
        _Phase.setup => _buildSetup(context),
        _Phase.countdown => _buildCountdown(context),
        _Phase.active => _buildActive(context),
        _Phase.done => _buildDone(context),
      },
    );
  }

  Widget _buildSetup(BuildContext context) {
    final l10n = context.l10n;
    final ready = _gps == _Gps.ready || _gps == _Gps.searching;
    final (gpsColor, gpsText) = switch (_gps) {
      _Gps.checking => (AppColors.textSecondary, l10n.gpsSearching),
      _Gps.searching => (AppColors.orange, l10n.gpsSearching),
      _Gps.ready => (AppColors.green, l10n.gpsReady((_accuracy ?? 0).round())),
      _Gps.off => (AppColors.error, l10n.gpsOff),
      _Gps.denied => (AppColors.error, l10n.locationDenied),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.runMode)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  for (final a in RunActivity.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _ActivityTile(
                          activity: a,
                          selected: a == _activity,
                          onTap: () => setState(() => _activity = a),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gpsColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded, size: 16, color: gpsColor),
                    const SizedBox(width: 6),
                    Text(
                      gpsText,
                      style: AppTextStyles.caption.copyWith(color: gpsColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Katta START — atrofida to'lqinlar.
              GestureDetector(
                onTap: ready ? _start : null,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        for (final shift in [0.0, 0.5])
                          Builder(
                            builder: (_) {
                              final t = (_pulse.value + shift) % 1;
                              return Container(
                                width: 180 + 80 * t,
                                height: 180 + 80 * t,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: ready ? 0.5 * (1 - t) : 0,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        AnimatedContainer(
                          duration: AppMotion.medium,
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ready
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            boxShadow: ready
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 40,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _activity.icon,
                                size: 44,
                                color: ready
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                              ),
                              Text(
                                l10n.start.toUpperCase(),
                                style: AppTextStyles.h1.copyWith(
                                  color: ready
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (_gps == _Gps.off || _gps == _Gps.denied)
                PrimaryButton(
                  label: l10n.openSettings,
                  variant: ButtonVariant.secondary,
                  expanded: true,
                  onPressed: () async {
                    _gps == _Gps.off
                        ? await Geolocator.openLocationSettings()
                        : await Geolocator.openAppSettings();
                    setState(() => _gps = _Gps.checking);
                    _initGps();
                  },
                )
              else
                Text(
                  l10n.runHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => ScaleTransition(
            scale: Tween(begin: 1.6, end: 1.0).animate(a),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Text(
            '$_countdown',
            key: ValueKey(_countdown),
            style: AppTextStyles.display.copyWith(
              fontSize: 180,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActive(BuildContext context) {
    final l10n = context.l10n;
    final s = _session!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              // Holat qatori: LIVE / PAUZA + faoliyat + GPS aniqligi.
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, _) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_paused ? AppColors.orange : AppColors.error)
                            .withValues(
                              alpha: _paused
                                  ? 1
                                  : 0.4 + 0.6 * (1 - _pulse.value),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (_paused ? l10n.paused : l10n.live).toUpperCase(),
                    style: AppTextStyles.overline.copyWith(
                      color: _paused ? AppColors.orange : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _activity.icon,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.gps_fixed_rounded,
                    size: 16,
                    color: (_accuracy ?? 99) <= 15
                        ? AppColors.green
                        : AppColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '±${(_accuracy ?? 0).round()} m',
                    style: AppTextStyles.captionSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Asosiy: real vaqtdagi kaloriya.
              TweenAnimationBuilder<double>(
                tween: Tween(end: s.kcal),
                duration: const Duration(milliseconds: 900),
                builder: (_, v, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.orange,
                        size: 40,
                      ),
                    ),
                    Text(
                      v.toStringAsFixed(v < 100 ? 1 : 0),
                      style: AppTextStyles.display.copyWith(
                        fontSize: 96,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(l10n.kcalBurned, style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                formatDuration(s.active),
                style: AppTextStyles.display.copyWith(
                  fontSize: 44,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _Metric(
                    value: (s.distanceM / 1000).toStringAsFixed(2),
                    unit: l10n.km,
                    label: l10n.distance,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Metric(
                    value: formatPace(s.currentPaceSecPerKm),
                    unit: l10n.minPerKm,
                    label: l10n.pace,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _Metric(
                    value: s.speedKmh.toStringAsFixed(1),
                    unit: l10n.kmh,
                    label: l10n.speed,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: ColoredBox(
                    color: AppColors.surface,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => RouteSketch(
                        points: s.route,
                        pulse: _paused ? 0 : _pulse.value,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _paused ? l10n.resume : l10n.pause,
                      icon: _paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      variant: _paused
                          ? ButtonVariant.primary
                          : ButtonVariant.secondary,
                      onPressed: _togglePause,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _HoldToStop(
                      controller: _hold,
                      label: l10n.holdToStop,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
    final l10n = context.l10n;
    final s = _session!;
    final cards = <Widget>[
      Text(l10n.runSummary, style: AppTextStyles.display),
      Text(_activity.label(context), style: AppTextStyles.bodySecondary),
      SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: ColoredBox(
            color: AppColors.surface,
            child: RouteSketch(points: s.route),
          ),
        ),
      ),
      Row(
        children: [
          _Metric(
            value: (s.distanceM / 1000).toStringAsFixed(2),
            unit: l10n.km,
            label: l10n.distance,
            big: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Metric(
            value: s.kcal.round().toString(),
            unit: l10n.kcalLabel,
            label: l10n.kcalBurned,
            big: true,
          ),
        ],
      ),
      Row(
        children: [
          _Metric(
            value: formatDuration(s.active),
            unit: '',
            label: l10n.duration,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Metric(
            value: formatPace(s.avgPaceSecPerKm),
            unit: l10n.minPerKm,
            label: l10n.avgPace,
          ),
        ],
      ),
      if (s.splits.isNotEmpty)
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.splits, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              for (final (i, d) in s.splits.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          l10n.kmSplit(i + 1),
                          style: AppTextStyles.captionSecondary,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            // Tezroq km — uzunroq chiziq.
                            value:
                                (s.splits
                                            .reduce((a, b) => a < b ? a : b)
                                            .inSeconds /
                                        d.inSeconds)
                                    .clamp(0.1, 1.0),
                            minHeight: 8,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surfaceLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(formatDuration(d), style: AppTextStyles.title),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: cards.length,
                separatorBuilder: (_, i) =>
                    SizedBox(height: i == 0 ? 0 : AppSpacing.md),
                itemBuilder: (_, i) => FadeSlideIn(index: i, child: cards[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.discard,
                      variant: ButtonVariant.secondary,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: l10n.saveRoutine,
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.selected,
    required this.onTap,
  });

  final RunActivity activity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnPrimary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(activity.icon, color: fg, size: 28),
            const SizedBox(height: 4),
            Text(
              activity.label(context),
              style: AppTextStyles.title.copyWith(color: fg, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.unit,
    required this.label,
    this.big = false,
  });

  final String value;
  final String unit;
  final String label;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.captionSecondary),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: value,
                  style: (big ? AppTextStyles.h1 : AppTextStyles.h2).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.captionSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bosib turib to'xtatish: qizil to'lqin chapdan o'ngga to'ladi.
class _HoldToStop extends StatelessWidget {
  const _HoldToStop({required this.controller, required this.label});

  final AnimationController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        controller.forward();
      },
      onTapUp: (_) => controller.status == AnimationStatus.completed
          ? null
          : controller.reverse(),
      onTapCancel: () => controller.status == AnimationStatus.completed
          ? null
          : controller.reverse(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox(
          height: 54,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) => Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.error.withValues(alpha: 0.18),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: controller.value,
                  child: const ColoredBox(
                    color: AppColors.error,
                    child: SizedBox.expand(),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stop_rounded, color: AppColors.white),
                      const SizedBox(width: 6),
                      Text(label, style: AppTextStyles.button),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
