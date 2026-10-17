import 'package:flutter/material.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../setup/setup_profile.dart';
import '../data/workout_models.dart';

extension ActivityLevelL10n on ActivityLevel {
  String label(BuildContext context) => switch (this) {
    ActivityLevel.beginner => context.l10n.beginner,
    ActivityLevel.intermediate => context.l10n.intermediate,
    ActivityLevel.advanced => context.l10n.advanced,
  };

  /// Rasmdagi "AAA Hard" ko'rsatkichi: nechta chiziq to'liq.
  int get bars => index + 1;
}

/// design/2.png "Browse" — rasm ustida nom, pastda vaqt va daraja.
class RoutineCard extends StatelessWidget {
  const RoutineCard({super.key, required this.routine, required this.onTap});

  final Routine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ImageCard(
      asset: AppImages.workout(routine.id),
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            routine.titleOf(context),
            style: AppTextStyles.title.copyWith(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                size: 14,
                color: AppColors.white,
              ),
              Text(
                context.l10n.minutes(routine.minutes),
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              LevelBars(level: routine.level),
              const SizedBox(width: 4),
              Text(routine.level.label(context), style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class LevelBars extends StatelessWidget {
  const LevelBars({
    super.key,
    required this.level,
    this.color = AppColors.primary,
  });

  final ActivityLevel level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 3,
            height: 6.0 + i * 3,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: i < level.bars ? color : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}
