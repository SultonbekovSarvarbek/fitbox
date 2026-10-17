import 'package:flutter/material.dart';
import '../../core/assets/app_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/primary_button.dart';
import '../ai/tts/voice_coach.dart';
import 'data/workout_models.dart';
import 'widgets/routine_card.dart';

/// Mashg'ulot tafsiloti — design/2.png (o'rta ustun):
/// katta rasm, nom, chip'lar, About, Level/Exercises/Focus, mashqlar ro'yxati.
class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final routine = ref.watch(routineByIdProvider(id));
    if (routine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notFound)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              ImageCard(
                motion: true,
                height: 380,
                asset: AppImages.workout(routine.id),
                radius: 0,
                icon: Icons.sports_gymnastics_rounded,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(routine.titleOf(context), style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        IconChip(
                          icon: Icons.play_arrow_rounded,
                          label: l10n.minutes(routine.minutes),
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconChip(
                          icon: Icons.local_fire_department_rounded,
                          label: l10n.kcal(routine.kcal),
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.about, style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            [
                              ?routine.descriptionOf(context),
                              l10n.routineAbout(
                                routine.exercises.length,
                                routine.minutes,
                              ),
                            ].join('\n\n'),
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              _Fact(
                                label: l10n.level,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LevelBars(level: routine.level),
                                    const SizedBox(width: 4),
                                    Text(
                                      routine.level.label(context),
                                      style: AppTextStyles.title,
                                    ),
                                  ],
                                ),
                              ),
                              _Fact(
                                label: l10n.exercisesLabel,
                                child: Text(
                                  '${routine.exercises.length}',
                                  style: AppTextStyles.title,
                                ),
                              ),
                              _Fact(
                                label: l10n.focusArea,
                                child: Text(
                                  l10n.fullBody,
                                  style: AppTextStyles.title,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(
                            Icons.record_voice_over_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.voiceGuide,
                              style: AppTextStyles.title,
                            ),
                          ),
                          Switch(
                            value: ref.watch(voiceEnabledProvider),
                            onChanged: ref
                                .read(voiceEnabledProvider.notifier)
                                .set,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: AppColors.textOnPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Text(l10n.exercisesLabel, style: AppTextStyles.h3),
                        const Spacer(),
                        Text(
                          l10n.exercisesCount(routine.exercises.length),
                          style: AppTextStyles.captionSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final e in routine.exercises)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              MediaPlaceholder(
                                asset: AppImages.exercise(e.name),
                                width: 64,
                                height: 64,
                                radius: AppRadius.md,
                                iconSize: 24,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.nameOf(context),
                                      style: AppTextStyles.title.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      e.seconds != null
                                          ? l10n.setsSeconds(e.sets, e.seconds!)
                                          : l10n.setsReps(e.sets, e.reps),
                                      style: AppTextStyles.captionSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ],
          ),
          // Orqaga tugmasi rasm ustida
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                background: AppColors.black.withValues(alpha: 0.5),
                onTap: () => context.pop(),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: l10n.startWorkout,
                expanded: true,
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push(Routes.player(routine.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.captionSecondary),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
