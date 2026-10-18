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
import '../../core/widgets/section_title.dart';
import '../market/data/market_models.dart' show Product, recommendProducts;
import '../market/data/sports_recommendation.dart';
import '../market/data/subscription_models.dart';
import '../market/market_screen.dart'
    show BestPlanCard, GoalL10n, PlanTile, ProductCard, marketActions;
import '../market/subscription_detail_screen.dart' show subscriptionStatusInfo;
import '../setup/setup_profile.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Главная: спортпит + подписка на питание, подобранные по полу и анкете,
/// которые человек указал при регистрации. Полный каталог — во вкладке «Магазин».
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(userProvider);
    final rec = recommendFor(user);
    final t = rec.targets;
    // Подборка с пояснением (витрина по анкете) + товары, сделанные для этого пола,
    // чтобы блок не состоял только из «общих» товаров.
    final shown = <Product>[for (final s in rec.supplements) s.product];
    for (final p in recommendProducts(
      user.goal,
      gender: user.gender,
      take: 8,
    )) {
      if (!shown.any((x) => x.id == p.id)) shown.add(p);
    }
    final products = shown.take(6).toList();
    final live = ref
        .watch(subscriptionsProvider)
        .where((s) => s.isLive)
        .firstOrNull;
    final women = user.gender == Gender.female;
    final name = user.displayName.isNotEmpty ? user.displayName : l10n.friend;
    final accent = women ? const Color(0xFFFF6FA8) : const Color(0xFF5AA9FF);

    Widget macro(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          Text(label, style: AppTextStyles.captionSecondary),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          _t(context, 'Hi, $name', 'Salom, $name', 'Привет, $name'),
          style: AppTextStyles.h2,
        ),
        actions: marketActions(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          // Кому подборка и суточная норма.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          women ? Icons.female_rounded : Icons.male_rounded,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              women
                                  ? _t(
                                      context,
                                      'Picked for women',
                                      'Ayollar uchun tanlov',
                                      'Подборка для женщин',
                                    )
                                  : _t(
                                      context,
                                      'Picked for men',
                                      'Erkaklar uchun tanlov',
                                      'Подборка для мужчин',
                                    ),
                              style: AppTextStyles.title,
                            ),
                            Text(
                              '${user.weightKg} ${l10n.kg} · ${user.goal.label(context)}',
                              style: AppTextStyles.captionSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      macro('${t.fat} g', _t(context, 'fat', "yog'", 'жиры')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Спортпит.
          SectionTitle(
            title: women
                ? _t(
                    context,
                    'Sports nutrition for women',
                    'Ayollar uchun sportpit',
                    'Спортпит для женщин',
                  )
                : _t(
                    context,
                    'Sports nutrition for men',
                    'Erkaklar uchun sportpit',
                    'Спортпит для мужчин',
                  ),
            onSeeAll: () => context.go(Routes.shop),
          ),
          SizedBox(
            height: 250,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) => SizedBox(
                width: 170,
                child: ProductCard(product: products[i]),
              ),
            ),
          ),

          // Подписка на питание.
          SectionTitle(
            title: _t(
              context,
              'Meal subscription',
              'Ovqat obunasi',
              'Подписка на питание',
            ),
            onSeeAll: () => context.go(Routes.subscription),
          ),
          if (live != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _LiveSubscription(sub: live),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: BestPlanCard(plan: rec.plans.first, targetKcal: t.kcal),
            ),
            for (final p in rec.plans.skip(1))
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: PlanTile(plan: p),
              ),
          ],
        ],
      ),
    );
  }
}

/// Уже оформленная подписка: статус и ближайшие приёмы пищи; тап — управление.
class _LiveSubscription extends StatelessWidget {
  const _LiveSubscription({required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final (status, color) = subscriptionStatusInfo(context, sub);
    return AppCard(
      color: AppColors.primary,
      onTap: () => context.push(Routes.mySubscription(sub.id)),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.textOnPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              sub.plan?.title.of(context) ?? sub.planId,
              style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              sub.slots
                  .map((m) => '${m.label.of(context)} ${m.window}')
                  .join(' · '),
            ),
          ],
        ),
      ),
    );
  }
}
