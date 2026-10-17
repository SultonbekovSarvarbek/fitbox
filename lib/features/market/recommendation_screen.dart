import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';
import '../setup/setup_screen.dart' show trainingTypeNames;
import 'data/market_models.dart';
import 'data/sports_recommendation.dart';
import 'market_screen.dart' show GoalL10n, categoryIcon;

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Anketadan keyin: "Sizga mos tanlov" — kunlik me'yor, sportpit va ovqat obunasi.
class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(userProvider);
    final rec = recommendFor(user);
    final cart = ref.watch(cartProvider);
    final t = rec.targets;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.h2),
    );

    Widget macro(String value, String name) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          Text(name, style: AppTextStyles.captionSecondary),
        ],
      ),
    );

    final types = user.trainingDays == 0
        ? _t(context, 'no workouts', "mashg'ulot yo'q", 'без тренировок')
        : '${user.trainingDays} ${_t(context, 'days/week', 'kun/hafta', 'дн./нед.')}: '
              '${user.trainingTypes.map((e) => trainingTypeNames[e]!.of(context)).join(', ')}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _t(
            context,
            'Picked for you',
            'Sizga mos tanlov',
            'Подобрано для вас',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.weightKg} ${l10n.kg} · ${user.goal.label(context)}',
                          style: AppTextStyles.title,
                        ),
                        Text(types, style: AppTextStyles.captionSecondary),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            macro('${t.kcal}', l10n.kcalLabel),
                            macro(
                              '${t.protein} g',
                              _t(context, 'protein', 'oqsil', 'белок'),
                            ),
                            macro(
                              '${t.carbs} g',
                              _t(context, 'carbs', 'uglevod', 'углеводы'),
                            ),
                            macro(
                              '${t.fat} g',
                              _t(context, 'fat', "yog'", 'жиры'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  heading(
                    _t(
                      context,
                      'Sports nutrition for you',
                      'Sizga sportpit',
                      'Спортпит для вас',
                    ),
                  ),
                  for (final pick in rec.supplements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _PickCard(
                        pick: pick,
                        inCart: cart[pick.product.id] ?? 0,
                        onAdd: () => ref
                            .read(cartProvider.notifier)
                            .add(pick.product.id),
                      ),
                    ),
                  heading(
                    _t(
                      context,
                      'Meal subscription',
                      'Ovqat obunasi',
                      'Подписка на питание',
                    ),
                  ),
                  Text(
                    _t(
                      context,
                      'A courier brings breakfast, lunch and dinner every day. Fits about ${t.kcal} kcal.',
                      "Kuryer har kuni nonushta, tushlik va kechki ovqat olib keladi. Taxminan ${t.kcal} kkalga mos.",
                      'Курьер каждый день привозит завтрак, обед и ужин. Подходит под ~${t.kcal} ккал.',
                    ),
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < rec.plans.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _PlanCard(plan: rec.plans[i], best: i == 0),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: _t(
                  context,
                  'Go to the shop',
                  "Do'konga o'tish",
                  'Перейти в магазин',
                ),
                expanded: true,
                onPressed: () => context.go(Routes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  const _PickCard({
    required this.pick,
    required this.inCart,
    required this.onAdd,
  });

  final SupplementPick pick;
  final int inCart;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = pick.product;
    return AppCard(
      onTap: () => context.push(Routes.product(p.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: p.image != null ? Colors.white : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: p.image != null
                ? Image.asset(p.image!, fit: BoxFit.contain)
                : Icon(categoryIcon(p.category), color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.brand.toUpperCase(),
                  style: AppTextStyles.captionSecondary,
                ),
                Text(
                  p.name.of(context),
                  style: AppTextStyles.title,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  pick.reason.of(context),
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      formatSum(context, p.price),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: onAdd,
                      icon: Icon(
                        inCart > 0 ? Icons.check_rounded : Icons.add_rounded,
                        size: 18,
                      ),
                      label: Text(
                        inCart > 0
                            ? '× $inCart'
                            : _t(context, 'Add', "Qo'shish", 'Добавить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.best});

  final MealPlanOffer plan;
  final bool best;

  @override
  Widget build(BuildContext context) {
    final fg = best ? AppColors.textOnPrimary : AppColors.textPrimary;
    return AppCard(
      color: best ? AppColors.primary : AppColors.surface,
      onTap: () => context.push(Routes.subscribe(plan.id)),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (best)
                    Text(
                      _t(context, 'BEST MATCH', 'ENG MOS', 'ЛУЧШИЙ ВЫБОР'),
                      style: AppTextStyles.caption.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    plan.title.of(context),
                    style: AppTextStyles.title.copyWith(color: fg),
                  ),
                  Text(
                    '${context.l10n.kcal(plan.kcal)} · '
                    '${formatSum(context, plan.pricePerDay)} / ${_t(context, 'day', 'kun', 'день')}',
                    style: AppTextStyles.captionSecondary.copyWith(
                      color: best ? fg : null,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: fg),
          ],
        ),
      ),
    );
  }
}
