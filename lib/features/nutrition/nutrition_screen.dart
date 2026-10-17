import 'package:flutter/material.dart';
import '../progress/data/progress_models.dart';
import 'data/nutrition_goals.dart';
import '../food/food_scan_screen.dart';
import '../food/data/food_models.dart';
import '../../core/widgets/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/assets/app_images.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/week_strip.dart';
import 'data/nutrition_models.dart';
import 'widgets/kcal_gauge.dart';

extension MealTypeL10n on MealType {
  String label(BuildContext context) => switch (this) {
    MealType.breakfast => context.l10n.breakfast,
    MealType.lunch => context.l10n.lunch,
    MealType.dinner => context.l10n.dinner,
  };
}

/// 7.3 Nutrition — design/1.png (o'ng telefon).
/// 7.3.1 Meal Plans: kaloriya o'lchagich, makrolar, kunlik ovqatlar.
/// 7.3.2 Meal Ideas: Breakfast / Lunch / Dinner.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _tab = 0;
  var _mealType = MealType.breakfast;
  var _day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.nutrition, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.mealPlans, l10n.mealIdeas],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _tab == 0
                ? _MealPlanTab(
                    day: _day,
                    onDay: (d) => setState(() => _day = d),
                  )
                : Column(
                    children: [
                      PillTabs(
                        labels: [
                          for (final t in MealType.values) t.label(context),
                        ],
                        selected: _mealType.index,
                        onChanged: (i) =>
                            setState(() => _mealType = MealType.values[i]),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(child: _MealIdeasTab(type: _mealType)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MealPlanTab extends ConsumerWidget {
  const _MealPlanTab({required this.day, required this.onDay});

  final DateTime day;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final target = ref.watch(dailyTargetsProvider);
    final eaten = ref.watch(todayTotalsProvider);
    // Mashg'ulot/yugurishda sarflangan — kunlik "byudjet"ga qo'shiladi.
    final burned = ref.watch(todayBurnedKcalProvider);
    final remaining = target.kcal - eaten.kcal + burned;
    final today = ref.watch(todayFoodProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        WeekStrip(selected: day, onSelect: onDay),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Text(l10n.calories, style: AppTextStyles.captionSecondary),
                  const Spacer(),
                  Text(l10n.today, style: AppTextStyles.caption),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              KcalGauge(
                value: eaten.kcal / (target.kcal + burned),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUp(
                      value: eaten.kcal.toDouble(),
                      builder: (_, v) =>
                          Text('${v.round()}', style: AppTextStyles.h1),
                    ),
                    Text(
                      l10n.ofKcal(target.kcal + burned),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Yeyilgan · Sarflangan · Qolgan
              Row(
                children: [
                  _KcalStat(
                    icon: Icons.restaurant_rounded,
                    color: AppColors.primary,
                    value: eaten.kcal,
                    label: l10n.eatenLabel,
                  ),
                  _KcalStat(
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.orange,
                    value: burned,
                    label: l10n.burnedLabel,
                  ),
                  _KcalStat(
                    icon: Icons.flag_rounded,
                    color: remaining >= 0 ? AppColors.green : AppColors.error,
                    value: remaining.abs(),
                    label: remaining >= 0
                        ? l10n.remainingLabel
                        : l10n.overLabel,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _MacroTile(
                    label: l10n.carbs,
                    value: eaten.carbs,
                    goal: target.carbs,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MacroTile(
                    label: l10n.protein,
                    value: eaten.protein,
                    goal: target.protein,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _MacroTile(
                    label: l10n.fat,
                    value: eaten.fat,
                    goal: target.fat,
                    color: AppColors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(
          title: l10n.dailyMeal,
          action: l10n.editPlan,
          onSeeAll: () {},
        ),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.customizePlanHint, style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.generateWithAi,
                          style: AppTextStyles.captionSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ],
          ),
          onTap: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ShopEntry(
                icon: Icons.delivery_dining_rounded,
                label: l10n.mealDelivery,
                onTap: () => context.push(Routes.market),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ShopEntry(
                icon: Icons.storefront_rounded,
                label: l10n.sportNutrition,
                onTap: () => context.push('${Routes.market}?tab=store'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(
          title: l10n.eatenToday,
          action: l10n.addFood,
          onSeeAll: () => context.push(Routes.foodScan),
        ),
        if (today.isEmpty)
          AppCard(
            onTap: () => context.push(Routes.foodScan),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.noFoodToday,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          for (final e in today) ...[
            _FoodRow(entry: e),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.md),
        SectionTitle(title: l10n.recommendations),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: demoMeals.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) =>
                SizedBox(width: 160, child: _MealCard(meal: demoMeals[i])),
          ),
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  final String label;
  final int value;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.captionSecondary),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: goal == 0 ? 0 : (value / goal).clamp(0, 1).toDouble(),
                minHeight: 4,
                color: color,
                backgroundColor: AppColors.border,
              ),
            ),
            const SizedBox(height: 6),
            Text('$value / ${goal}g', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _MealIdeasTab extends StatelessWidget {
  const _MealIdeasTab({required this.type});

  final MealType type;

  @override
  Widget build(BuildContext context) {
    final meals = demoMeals.where((m) => m.type == type).toList();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: meals.length,
      itemBuilder: (_, i) => _MealCard(meal: meals[i]),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return ImageCard(
      asset: AppImages.meal(meal.id),
      icon: Icons.ramen_dining_rounded,
      onTap: () => context.push(Routes.meal(meal.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(meal.titleOf(context), style: AppTextStyles.title, maxLines: 2),
          const SizedBox(height: 2),
          Text(
            '${context.l10n.minutes(meal.minutes)} · ${context.l10n.kcal(meal.kcal)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends ConsumerWidget {
  const _FoodRow({required this.entry});

  final FoodEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final photo = entry.photoPath == null ? null : File(entry.photoPath!);
    return Dismissible(
      key: ValueKey(entry.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => ref.read(foodLogProvider.notifier).remove(entry),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 56,
                height: 56,
                child: photo != null && photo.existsSync()
                    ? Image.file(photo, fit: BoxFit.cover)
                    : const MediaPlaceholder(
                        icon: Icons.restaurant_rounded,
                        radius: 0,
                        iconSize: 22,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.slot.label(context),
                    style: AppTextStyles.captionSecondary,
                  ),
                  Text(entry.name, style: AppTextStyles.title, maxLines: 1),
                  if (entry.protein + entry.carbs + entry.fat > 0)
                    Text(
                      l10n.macrosShort(entry.protein, entry.carbs, entry.fat),
                      style: AppTextStyles.captionSecondary,
                    ),
                ],
              ),
            ),
            Text(
              l10n.kcal(entry.kcal),
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _KcalStat extends StatelessWidget {
  const _KcalStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              CountUp(
                value: value.toDouble(),
                builder: (_, v) =>
                    Text('${v.round()}', style: AppTextStyles.h3),
              ),
            ],
          ),
          Text(label, style: AppTextStyles.captionSecondary),
        ],
      ),
    );
  }
}

class _ShopEntry extends StatelessWidget {
  const _ShopEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.title, maxLines: 2)),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
