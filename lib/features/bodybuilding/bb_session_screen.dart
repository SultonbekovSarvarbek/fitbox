import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../progress/data/progress_models.dart';
import '../run/run_tracker.dart' show formatDuration;
import '../setup/setup_profile.dart';
import '../workout/data/met.dart';
import 'data/bb_logic.dart';
import 'data/bb_models.dart';
import 'data/exercise_video.dart';
import '../ai/pose/pose_analyzer.dart';
import '../ai/pose/pose_check_screen.dart';

part 'bb_session_screen_widgets.dart';

/// Og'ir atletika (vigorous) MET — Compendium.
const _liftingMet = 6.0;

/// Mashg'ulot: har bir set — og'irlik × takror ✓, keyin avtomatik dam olish taymeri.
class BbSessionScreen extends ConsumerStatefulWidget {
  const BbSessionScreen({
    super.key,
    required this.programId,
    required this.dayIndex,
  });

  final String programId;
  final int dayIndex;

  @override
  ConsumerState<BbSessionScreen> createState() => _BbSessionScreenState();
}

class _BbSessionScreenState extends ConsumerState<BbSessionScreen> {
  late final BbProgram _program = programById(widget.programId);
  late final BbDay _day =
      _program.days[widget.dayIndex.clamp(0, _program.days.length - 1)];
  late final List<List<_SetRow>> _rows;

  final _clock = Stopwatch()..start();
  Timer? _ticker;

  /// Dam olish taymeri: qolgan va umumiy soniya.
  int _rest = 0;
  int _restTotal = 0;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final p in _day.items)
        () {
          final last = ref.read(lastSetsProvider(p.key));
          final next = suggestNextWeight(
            lastSets: last,
            repsMax: p.repsMax,
            lowerBody: p.exercise.lowerBody,
          );
          return [
            for (var i = 0; i < p.sets; i++)
              _SetRow(weight: next, reps: p.repsMax),
          ];
        }(),
    ];
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_rest > 0) {
          _rest--;
          if (_rest == 0) HapticFeedback.heavyImpact();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final r in _rows.expand((e) => e)) {
      r.dispose();
    }
    super.dispose();
  }

  void _toggleDone(int ex, int i) {
    final row = _rows[ex][i];
    if (!row.done && row.result == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      row.done = !row.done;
      if (row.done) {
        _restTotal = _day.items[ex].exercise.restSec;
        _rest = _restTotal;
      }
    });
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    final logged = <LoggedExercise>[
      for (final (i, p) in _day.items.indexed)
        LoggedExercise(p.key, [
          for (final r in _rows[i])
            if (r.done && r.result != null) r.result!,
        ]),
    ].where((e) => e.sets.isNotEmpty).toList();

    if (logged.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noSetsDone)));
      return;
    }

    // Yangi rekordlar — saqlashdan OLDINGI holat bilan solishtiramiz.
    final newPrs = <String>[
      for (final e in logged)
        if (e.sets
                    .map((s) => estimate1Rm(s.weightKg, s.reps))
                    .reduce((a, b) => a > b ? a : b) >
                ref.read(personalRecordProvider(e.key)) &&
            ref.read(personalRecordProvider(e.key)) > 0)
          bbExercises[e.key]!.name.of(context),
    ];

    final minutes = (_clock.elapsed.inSeconds / 60).ceil().clamp(1, 600);
    final session = BbSession(
      date: DateTime.now(),
      programId: _program.id,
      dayIndex: widget.dayIndex,
      minutes: minutes,
      exercises: logged,
    );
    ref.read(bbHistoryProvider.notifier).add(session);
    final weight = ref.read(userProvider).weightKg.toDouble();
    ref
        .read(workoutLogProvider.notifier)
        .add(
          LogEntry(
            date: session.date,
            title: 'Bodybuilding · ${_day.name.en}',
            minutes: minutes,
            kcal: kcalFor(
              met: _liftingMet,
              weightKg: weight,
              minutes: minutes.toDouble(),
            ),
            level: const [
              'beginner',
              'intermediate',
              'advanced',
            ][_program.level],
          ),
        );
    _clock.stop();
    HapticFeedback.heavyImpact();

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.sessionDone, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _Stat(
                  value: (session.volume / 1000).toStringAsFixed(2),
                  label: l10n.tonnes,
                ),
                _Stat(value: '${session.setCount}', label: l10n.setsLabel),
                _Stat(
                  value: formatDuration(_clock.elapsed),
                  label: l10n.duration,
                ),
              ],
            ),
            if (newPrs.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                color: AppColors.primary.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${l10n.newPr}: ${newPrs.join(', ')}',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.close,
              expanded: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doneSets = _rows.expand((e) => e).where((r) => r.done).length;
    final allSets = _rows.expand((e) => e).length;

    return PopScope(
      canPop: doneSets == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(l10n.leaveSessionTitle, style: AppTextStyles.h3),
            content: Text(
              l10n.leaveSessionText,
              style: AppTextStyles.bodySecondary,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.discard,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_day.name.of(context), style: AppTextStyles.h3),
              Text(
                '${formatDuration(_clock.elapsed)} · $doneSets/$allSets',
                style: AppTextStyles.captionSecondary,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                180,
              ),
              itemCount: _day.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, ex) => FadeSlideIn(
                index: ex,
                child: _ExerciseCard(
                  planned: _day.items[ex],
                  rows: _rows[ex],
                  onToggle: (i) => _toggleDone(ex, i),
                  onAddSet: () => setState(() {
                    final last = _rows[ex].lastOrNull;
                    _rows[ex].add(
                      _SetRow(
                        weight: last?.result?.weightKg ?? 0,
                        reps: last?.result?.reps ?? _day.items[ex].repsMax,
                      ),
                    );
                  }),
                  onChanged: () => setState(() {}),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.medium,
                        child: _rest > 0
                            ? _RestBar(
                                key: const ValueKey('rest'),
                                left: _rest,
                                total: _restTotal,
                                onSkip: () => setState(() => _rest = 0),
                                onAdd: () => setState(() {
                                  _rest += 30;
                                  _restTotal += 30;
                                }),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(
                        label: l10n.finishSession,
                        icon: Icons.flag_rounded,
                        expanded: true,
                        onPressed: _finish,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
