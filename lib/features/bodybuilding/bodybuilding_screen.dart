import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';
import 'data/bb_logic.dart';
import 'data/bb_models.dart';
import 'data/exercise_video.dart';

/// Bodybuilding: navbatdagi mashg'ulot, rekordlar, haftalik hajm, dasturlar, tarix.
class BodybuildingScreen extends ConsumerWidget {
  const BodybuildingScreen({super.key});

  static const _bigLifts = [
    'Bench Press',
    'Back Squat',
    'Deadlift',
    'Overhead Press',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final program = programById(ref.watch(bbProgramIdProvider));
    final nextDay = ref.watch(bbNextDayProvider);
    final day = program.days[nextDay];
    final history = ref.watch(bbHistoryProvider);
    final weekly = ref.watch(weeklySetsByMuscleProvider);
    final totalSets = day.items.fold(0, (s, p) => s + p.sets);

    final sections = <Widget>[
      // Navbatdagi mashg'ulot.
      AppCard(
        color: AppColors.primary,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nextSession.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day.name.of(context),
              style: AppTextStyles.display.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            Text(
              '${program.name.of(context)} · ${l10n.exercisesCount(day.items.length)} · ${l10n.setsCount(totalSets)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in day.items)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      p.exercise.name.of(context),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push(Routes.bbSession(program.id, nextDay)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textOnPrimary,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 54),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  l10n.startSession,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Rekordlar.
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title: l10n.personalRecords),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.9,
            children: [
              for (final key in _bigLifts)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bbExercises[key]!.name.of(context),
                        style: AppTextStyles.captionSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Builder(
                        builder: (_) {
                          final pr = ref.watch(personalRecordProvider(key));
                          return Text.rich(
                            TextSpan(
                              text: pr == 0
                                  ? '—'
                                  : formatKg(pr.roundToDouble()),
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.primary,
                              ),
                              children: [
                                if (pr > 0)
                                  TextSpan(
                                    text: ' ${l10n.kg} · 1RM',
                                    style: AppTextStyles.captionSecondary,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),

      // Haftalik hajm (mushak bo'yicha setlar).
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.weeklySetsTitle, style: AppTextStyles.title),
              Text(l10n.weeklySetsHint, style: AppTextStyles.captionSecondary),
              const SizedBox(height: AppSpacing.md),
              for (final m in Muscle.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: Text(
                          m.label(context),
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: (weekly[m]! / 20).clamp(0, 1),
                            ),
                            duration: AppMotion.slow,
                            curve: AppMotion.curve,
                            builder: (_, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 10,
                              backgroundColor: AppColors.surfaceLight,
                              // 10–20 set — optimal zona (lime).
                              color: weekly[m]! >= 10
                                  ? AppColors.primary
                                  : AppColors.orange,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${weekly[m]}',
                          textAlign: TextAlign.end,
                          style: AppTextStyles.title,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

      // Texnika videolari — mushak guruhi bo'yicha.
      const _VideoLibrary(),

      // Dasturlar.
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title: l10n.programs),
          for (final p in bbPrograms)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _ProgramCard(
                program: p,
                selected: p.id == program.id,
                onTap: () => ref.read(bbProgramIdProvider.notifier).set(p.id),
              ),
            ),
        ],
      ),

      // Tarix.
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title: l10n.recentSessions),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l10n.noSessionsYet,
                style: AppTextStyles.bodySecondary,
              ),
            )
          else
            for (final s in history.take(6))
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: _SessionTile(session: s),
              ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.bodybuilding, style: AppTextStyles.h2),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, i) => FadeSlideIn(
          index: i,
          child: i == 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: sections[i],
                )
              : sections[i],
        ),
      ),
    );
  }
}

class _VideoLibrary extends StatefulWidget {
  const _VideoLibrary();

  @override
  State<_VideoLibrary> createState() => _VideoLibraryState();
}

class _VideoLibraryState extends State<_VideoLibrary> {
  var _muscle = Muscle.chest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = bbExercises.values.where((e) => e.muscle == _muscle).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l10n.techniqueVideos),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.techniqueVideosHint,
            style: AppTextStyles.captionSecondary,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              for (final m in Muscle.values)
                if (bbExercises.values.any((e) => e.muscle == m))
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => setState(() => _muscle = m),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: m == _muscle
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          m.label(context),
                          style: AppTextStyles.title.copyWith(
                            color: m == _muscle
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final e in list)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppCard(
              onTap: () => openTechniqueVideo(context, e),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.error,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name.of(context), style: AppTextStyles.title),
                        Text(
                          e.compound ? l10n.compoundLift : l10n.isolationLift,
                          style: AppTextStyles.captionSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.selected,
    required this.onTap,
  });

  final BbProgram program;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final level = [
      l10n.beginner,
      l10n.intermediate,
      l10n.advanced,
    ][program.level];
    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.name.of(context),
                    style: AppTextStyles.title,
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$level · ${l10n.daysPerWeek(program.days.length)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              program.description.of(context),
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final BbSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = programById(session.programId);
    final day = p.days[session.dayIndex.clamp(0, p.days.length - 1)];
    final locale = Localizations.localeOf(context).toString();
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.name.of(context), style: AppTextStyles.title),
                Text(
                  '${DateFormat.MMMd(locale).format(session.date)} · ${l10n.setsCount(session.setCount)} · ${l10n.minutes(session.minutes)}',
                  style: AppTextStyles.captionSecondary,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (session.volume / 1000).toStringAsFixed(1),
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              Text(l10n.tonnes, style: AppTextStyles.captionSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

/// Home'dagi kirish kartasi.
class BodybuildingEntryCard extends StatelessWidget {
  const BodybuildingEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PressableScale(
      child: AppCard(
        onTap: () => context.push(Routes.bodybuilding),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.bodybuilding, style: AppTextStyles.h3),
                  Text(
                    l10n.bodybuildingSubtitle,
                    style: AppTextStyles.captionSecondary,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
