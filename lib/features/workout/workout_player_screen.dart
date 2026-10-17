import 'dart:async';
import 'dart:math' as math;

import '../../core/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/primary_button.dart';
import '../ai/pose/pose_analyzer.dart';
import '../ai/pose/pose_check_screen.dart';
import '../ai/tts/voice_coach.dart';
import '../progress/data/progress_models.dart';
import '../setup/setup_profile.dart';
import 'data/met.dart';
import 'data/workout_models.dart';

enum _Phase { getReady, exercise, done }

/// Mashg'ulot rejimi — design/2.png:
/// "Get ready" (lime) → har bir mashq (katta "10" raqam, Previous/Next) → "Congratulation".
/// AI: ovozli ko'rsatma (TTS) — sanash, mashq nomi, oxirgi 3 soniya, tabrik.
class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  const WorkoutPlayerScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> {
  static const _readySeconds = 3;

  var _phase = _Phase.getReady;
  int _index = 0;
  int _left = _readySeconds;
  bool _paused = false;
  Timer? _timer;

  /// `dispose`da `ref` ishlatib bo'lmaydi — oldindan olib qo'yamiz.
  late final VoiceCoach _coach = ref.read(voiceCoachProvider);

  /// Haqiqiy faol vaqt (pauzalarsiz) — statistika uchun.
  final _total = Stopwatch();

  /// Joriy mashq vaqti — kaloriya har bir mashqning o'z MET qiymati bilan hisoblanadi.
  final _current = Stopwatch();
  double _kcal = 0;

  Routine get _routine => ref.read(routineByIdProvider(widget.id))!;
  Exercise get _exercise => _routine.exercises[_index];

  @override
  void initState() {
    super.initState();
    _coach; // dispose'dan oldin olinsin
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locale = Localizations.localeOf(context);
      final getReady = context.l10n.getReady;
      await ref.read(voiceCoachProvider).setLocale(locale);
      _say(getReady);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coach.stop();
    super.dispose();
  }

  void _say(String text) {
    if (ref.read(voiceEnabledProvider)) ref.read(voiceCoachProvider).say(text);
  }

  void _tick() {
    if (_paused || _phase == _Phase.done) return;
    if (_phase == _Phase.getReady) {
      if (_left <= 1) {
        _startExercise(0);
      } else {
        setState(() => _left--);
        _say('$_left');
      }
      return;
    }
    // Faqat vaqtga asoslangan mashqlarda taymer ishlaydi.
    if (_exercise.seconds == null) return;
    if (_left <= 1) {
      _next();
    } else {
      setState(() => _left--);
      if (_left <= 3) _say('$_left');
    }
  }

  /// Tugagan (yoki tark etilgan) mashq kaloriyasini jamg'aradi.
  void _flushExercise() {
    if (_phase != _Phase.exercise) return;
    final weight = ref.read(userProvider).weightKg.toDouble();
    _kcal +=
        activeMet(_exercise.met) * weight * _current.elapsed.inSeconds / 3600;
    _current
      ..reset()
      ..stop();
  }

  void _setPaused(bool v) {
    setState(() => _paused = v);
    if (v) {
      _total.stop();
      _current.stop();
    } else {
      _total.start();
      _current.start();
    }
  }

  void _startExercise(int i) {
    _flushExercise();
    _total.start();
    _current.start();
    final e = _routine.exercises[i];
    setState(() {
      _phase = _Phase.exercise;
      _index = i;
      _left = e.seconds ?? e.reps;
    });
    final l10n = context.l10n;
    _say(
      e.seconds != null
          ? l10n.ttsExerciseTimed(e.nameOf(context), e.seconds!)
          : l10n.ttsExerciseReps(e.nameOf(context), e.reps),
    );
  }

  void _next() {
    if (_index < _routine.exercises.length - 1) {
      _startExercise(_index + 1);
    } else {
      _finish();
    }
  }

  /// AI kamera tekshiruvi: taymer to'xtaydi, maqsadga yetilsa keyingi mashqqa o'tadi.
  Future<void> _openFormCheck(Exercise e, TrackedExercise tracked) async {
    setState(() => _paused = true);
    final reps = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PoseCheckScreen(
          exerciseName: e.nameOf(context),
          exercise: tracked,
          targetReps: tracked.targetFor(reps: e.reps, seconds: e.seconds),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _paused = false);
    if ((reps ?? 0) >= tracked.targetFor(reps: e.reps, seconds: e.seconds)) {
      _next();
    }
  }

  void _previous() {
    if (_index > 0) _startExercise(_index - 1);
  }

  void _finish() {
    _flushExercise();
    _total.stop();
    final r = _routine;
    ref
        .read(workoutLogProvider.notifier)
        .add(
          LogEntry(
            date: DateTime.now(),
            title: r.title,
            routineId: r.id,
            minutes: _doneMinutes,
            kcal: _kcal.round(),
            level: r.level.name,
          ),
        );
    setState(() => _phase = _Phase.done);
    _say(context.l10n.ttsFinished);
  }

  int get _doneMinutes => math.max(1, (_total.elapsed.inSeconds / 60).round());

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.getReady => _GetReady(seconds: _left),
      _Phase.exercise => _buildExercise(context),
      _Phase.done => _Congratulation(
        routine: _routine,
        minutes: _doneMinutes,
        kcal: _kcal.round(),
      ),
    };
  }

  Widget _buildExercise(BuildContext context) {
    final l10n = context.l10n;
    final total = _routine.exercises.length;
    final e = _exercise;
    final timed = e.seconds != null;
    final tracked = TrackedExercise.fromName(e.name);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MediaPlaceholder(
            asset: AppImages.exercise(e.name),
            icon: Icons.sports_gymnastics_rounded,
            radius: 0,
            iconSize: 120,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0xF2000000),
                ],
                stops: [0, 0.35, 0.8],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.close_rounded,
                        background: AppColors.black.withValues(alpha: 0.5),
                        onTap: () => context.pop(),
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1} / $total',
                        style: AppTextStyles.title,
                      ),
                      const Spacer(),
                      CircleIconButton(
                        icon: _paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        background: AppColors.black.withValues(alpha: 0.5),
                        onTap: () => _setPaused(!_paused),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      '$_left',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 140,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      timed ? l10n.secondsLabel : l10n.repsLabel,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(e.nameOf(context), style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l10n.setOf(e.sets), style: AppTextStyles.bodySecondary),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: (_index + 1) / total,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (tracked != null) ...[
                    PrimaryButton(
                      label: l10n.aiFormCheck,
                      icon: Icons.photo_camera_front_rounded,
                      variant: ButtonVariant.outline,
                      expanded: true,
                      onPressed: () => _openFormCheck(e, tracked),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.previous,
                          icon: Icons.arrow_back_rounded,
                          variant: ButtonVariant.secondary,
                          onPressed: _index == 0 ? null : _previous,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          label: _index == total - 1 ? l10n.finish : l10n.next,
                          onPressed: _next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GetReady extends StatelessWidget {
  const _GetReady({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.getReady,
              style: AppTextStyles.h1.copyWith(color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text(
                '$seconds',
                key: ValueKey(seconds),
                style: AppTextStyles.display.copyWith(
                  fontSize: 96,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Congratulation extends StatelessWidget {
  const _Congratulation({
    required this.routine,
    required this.minutes,
    required this.kcal,
  });

  final Routine routine;

  /// Haqiqiy bajarilgan vaqt va sarflangan kaloriya.
  final int minutes;
  final int kcal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                        width: 12,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.textOnPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.congratulation,
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.workoutCompleted(routine.titleOf(context)),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Badge(
                        icon: Icons.schedule_rounded,
                        text: l10n.minutes(minutes),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Badge(
                        icon: Icons.local_fire_department_rounded,
                        text: l10n.kcal(kcal),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textOnPrimary,
                        minimumSize: const Size(0, 54),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l10n.close,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textOnPrimary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
