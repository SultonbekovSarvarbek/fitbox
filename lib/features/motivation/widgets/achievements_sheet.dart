import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../data/motivation_providers.dart';

void showAchievements(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AchievementsSheet(),
  );
}

String achievementTitle(AppLocalizations l10n, String id) => switch (id) {
  'first' => l10n.achFirst,
  'streak3' => l10n.achStreak(3),
  'streak7' => l10n.achStreak(7),
  'workouts10' => l10n.achWorkouts(10),
  'workouts50' => l10n.achWorkouts(50),
  'kcal5000' => l10n.achKcal(5000),
  'km10' => l10n.achKm(10),
  'level5' => l10n.achLevel(5),
  _ => id,
};

class _AchievementsSheet extends ConsumerWidget {
  const _AchievementsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final d = ref.watch(disciplineProvider);
    final list = ref.watch(achievementsProvider);
    final unlocked = list.where((a) => a.unlocked).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${d.level}',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.levelShort(d.level), style: AppTextStyles.h2),
                    Text(
                      l10n.xpToNext(d.nextLevelXp - d.xp),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.xpHowTo, style: AppTextStyles.captionSecondary),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(l10n.achievements, style: AppTextStyles.h3),
              const Spacer(),
              Text(
                '$unlocked / ${list.length}',
                style: AppTextStyles.captionSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.25,
            children: [
              for (final a in list)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: a.unlocked
                        ? Border.all(color: AppColors.primary, width: 1.2)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        a.unlocked ? a.icon : Icons.lock_outline_rounded,
                        color: a.unlocked
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                      const Spacer(),
                      Text(
                        achievementTitle(l10n, a.id),
                        style: AppTextStyles.title.copyWith(
                          color: a.unlocked ? null : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: a.progress,
                          minHeight: 4,
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
