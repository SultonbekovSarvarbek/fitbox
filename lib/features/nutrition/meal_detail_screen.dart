import 'package:flutter/material.dart';
import '../../core/assets/app_images.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import 'data/nutrition_models.dart';
import 'nutrition_screen.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meal = mealById(id);
    if (meal == null) {
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
                height: 320,
                asset: AppImages.meal(meal.id),
                radius: 0,
                icon: Icons.ramen_dining_rounded,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      meal.type.label(context).toUpperCase(),
                      style: AppTextStyles.overline,
                    ),
                    Text(meal.titleOf(context), style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        IconChip(
                          icon: Icons.schedule_rounded,
                          label: l10n.minutes(meal.minutes),
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconChip(
                          icon: Icons.local_fire_department_rounded,
                          label: l10n.kcal(meal.kcal),
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
                    Row(
                      children: [
                        _Macro(
                          label: l10n.protein,
                          grams: meal.protein,
                          color: AppColors.yellow,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Macro(
                          label: l10n.carbs,
                          grams: meal.carbs,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Macro(
                          label: l10n.fat,
                          grams: meal.fat,
                          color: AppColors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.ingredients, style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.sm),
                          for (final ing in meal.ingredientsOf(context))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(ing, style: AppTextStyles.body),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.grams, required this.color});

  final String label;
  final int grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        child: Column(
          children: [
            Text('$grams g', style: AppTextStyles.h3.copyWith(color: color)),
            Text(label, style: AppTextStyles.captionSecondary),
          ],
        ),
      ),
    );
  }
}
