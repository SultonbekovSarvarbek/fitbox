part of 'market_screen.dart';

extension GoalL10n on Goal {
  String label(BuildContext context) => switch (this) {
    Goal.loseWeight => context.l10n.goalLoseWeight,
    Goal.gainWeight => context.l10n.goalGainWeight,
    Goal.muscleMass => context.l10n.goalMuscleMass,
    Goal.shapeBody => context.l10n.goalShapeBody,
    Goal.others => context.l10n.goalOthers,
  };
}

IconData categoryIcon(ProductCategory c) => switch (c) {
  ProductCategory.protein => Icons.sports_gymnastics_rounded,
  ProductCategory.creatine => Icons.bolt_rounded,
  ProductCategory.gainer => Icons.trending_up_rounded,
  ProductCategory.aminos => Icons.science_rounded,
  ProductCategory.vitamins => Icons.medication_rounded,
  ProductCategory.wellness => Icons.spa_rounded,
  ProductCategory.bars => Icons.cookie_rounded,
};

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.orange,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.marketDemoNote,
              style: AppTextStyles.caption.copyWith(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ovqat yetkazib berish
// ---------------------------------------------------------------------------

class _DeliveryTab extends ConsumerStatefulWidget {
  const _DeliveryTab();

  @override
  ConsumerState<_DeliveryTab> createState() => _DeliveryTabState();
}

class _DeliveryTabState extends ConsumerState<_DeliveryTab> {
  /// Boshida — anketadagi jinsga mos; foydalanuvchi o'zgartira oladi.
  late AudienceFilter _audience = audienceFilterFor(
    ref.read(userProvider).gender,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(userProvider);
    final target = ref.watch(dailyTargetsProvider);
    final gender = switch (_audience) {
      AudienceFilter.all => null,
      AudienceFilter.men => Gender.male,
      AudienceFilter.women => Gender.female,
    };
    final best = recommendPlans(
      targetKcal: target.kcal,
      goal: user.goal,
      gender: gender,
    ).first;
    final others = [
      for (final p in mealPlans)
        if (audienceVisible(p.audience, _audience)) p,
    ]..sort((a, b) => a.kcal.compareTo(b.kcal));
    String t(String en, String uz, String ru) => Tr(en, uz, ru).of(context);

    EdgeInsets pad([double bottom = 0]) =>
        EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom);

    final items = <Widget>[
      const _ActiveSubscriptions(),
      AudienceSwitch(
        value: _audience,
        onChanged: (v) => setState(() => _audience = v),
      ),
      const SizedBox(height: AppSpacing.md),
      // Bizning oshxona.
      Padding(
        padding: pad(AppSpacing.md),
        child: AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kitchenName, style: AppTextStyles.title),
                    const SizedBox(height: 2),
                    Text(
                      t(
                        'We cook it ourselves and a courier brings fresh meals three times a day: morning, lunch and evening. Pick a program for your goal.',
                        "Ovqatni o'zimiz tayyorlaymiz, kuryer kuniga uch mahal yangi taom olib keladi: ertalab, tushlikda va kechqurun. Maqsadingizga mos ratsionni tanlang.",
                        'Готовим сами, а курьер привозит свежие блюда три раза в день: утром, в обед и вечером. Выберите программу под вашу цель.',
                      ),
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Shaxsiy me'yor.
      Padding(
        padding: pad(),
        child: AppCard(
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourDailyNorm(target.kcal),
                      style: AppTextStyles.title,
                    ),
                    Text(
                      '${user.heightCm} ${l10n.cm} · ${user.weightKg} ${l10n.kg} · ${l10n.ageYears(user.age)} · ${user.goal.label(context)}',
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      SectionTitle(title: l10n.recommendedForYou),
      Padding(
        padding: pad(),
        child: BestPlanCard(plan: best, targetKcal: target.kcal),
      ),
      SectionTitle(
        title: t('All programs', 'Barcha ratsionlar', 'Все программы'),
      ),
      for (final p in others)
        Padding(
          padding: pad(AppSpacing.sm),
          child: PlanTile(plan: p),
        ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: items.length,
      itemBuilder: (_, i) => FadeSlideIn(index: i, child: items[i]),
    );
  }
}

/// Anketaga eng mos ratsion: katta karta, menyu namunasi va "Obuna bo'lish".
class BestPlanCard extends StatelessWidget {
  const BestPlanCard({super.key, required this.plan, required this.targetKcal});

  final MealPlanOffer plan;
  final int targetKcal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diff = plan.kcal - targetKcal;
    const fg = AppColors.textOnPrimary;
    return AppCard(
      color: AppColors.primary,
      onTap: () => context.push(Routes.subscribe(plan.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: fg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              l10n.bestMatch,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            plan.title.of(context),
            style: AppTextStyles.h1.copyWith(color: fg),
          ),
          Text(
            '${l10n.kcal(plan.kcal)} · ${l10n.mealsPerDay(plan.mealsPerDay)}',
            style: AppTextStyles.caption.copyWith(color: fg),
          ),
          Text(
            diff.abs() < 100
                ? l10n.matchesYourNorm
                : l10n.kcalFromNorm('${diff > 0 ? '+' : ''}$diff'),
            style: AppTextStyles.caption.copyWith(color: fg),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final m in plan.menu.take(3))
            Text(
              '• ${m.of(context)}',
              style: AppTextStyles.body.copyWith(color: fg),
            ),
          if (plan.menu.length > 3)
            Text('• …', style: AppTextStyles.body.copyWith(color: fg)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatSum(context, plan.pricePerDay)} / ${l10n.perDay}',
                  style: AppTextStyles.h3.copyWith(color: fg),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: fg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  Tr('Subscribe', "Obuna bo'lish", 'Оформить').of(context),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bitta ratsion qatori: nomi, kimga mos, kaloriya, kunlik narx.
class PlanTile extends StatelessWidget {
  const PlanTile({super.key, required this.plan});

  final MealPlanOffer plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      onTap: () => context.push(Routes.subscribe(plan.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        plan.title.of(context),
                        style: AppTextStyles.h3,
                      ),
                    ),
                    if (plan.audience != Audience.everyone) ...[
                      const SizedBox(width: 6),
                      AudienceBadge(audience: plan.audience),
                    ],
                  ],
                ),
                Text(
                  plan.tagline.of(context),
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.kcal(plan.kcal)} · ${l10n.mealsPerDay(plan.mealsPerDay)}',
                  style: AppTextStyles.captionSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatSum(context, plan.pricePerDay),
                style: AppTextStyles.title.copyWith(color: AppColors.primary),
              ),
              Text('/ ${l10n.perDay}', style: AppTextStyles.captionSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.total,
    required this.label,
    required this.onTap,
  });

  final int total;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: AppColors.primary,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sportpit
// ---------------------------------------------------------------------------

class _StoreTab extends ConsumerStatefulWidget {
  const _StoreTab();

  @override
  ConsumerState<_StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends ConsumerState<_StoreTab> {
  ProductCategory? _category;

  /// Boshida — anketadagi jinsga mos; foydalanuvchi o'zgartira oladi.
  late AudienceFilter _audience = audienceFilterFor(
    ref.read(userProvider).gender,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = ref.watch(userProvider).goal;
    final target = ref.watch(dailyTargetsProvider);
    final rec = recommendProducts(
      goal,
      gender: switch (_audience) {
        AudienceFilter.all => null,
        AudienceFilter.men => Gender.male,
        AudienceFilter.women => Gender.female,
      },
    );
    final list = [
      for (final p in products)
        if (audienceVisible(p.audience, _audience) &&
            (_category == null || p.category == _category))
          p,
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AudienceSwitch(
            value: _audience,
            onChanged: (v) => setState(() => _audience = v),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppCard(
              child: Row(
                children: [
                  const Icon(Icons.egg_alt_rounded, color: AppColors.yellow),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.proteinNeed(target.protein, goal.label(context)),
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.recommendedForYou)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 250,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: rec.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) =>
                  SizedBox(width: 170, child: ProductCard(product: rec[i])),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverToBoxAdapter(
          child: PillTabs(
            labels: [
              l10n.all,
              for (final c in ProductCategory.values)
                categoryNames[c]!.of(context),
            ],
            selected: _category == null ? 0 : _category!.index + 1,
            onChanged: (i) => setState(
              () => _category = i == 0 ? null : ProductCategory.values[i - 1],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => FadeSlideIn(
                index: i,
                child: ProductCard(product: list[i]),
              ),
              childCount: list.length,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final inCart = ref.watch(cartProvider)[product.id] ?? 0;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => context.push(Routes.product(product.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ProductImage(
                  product: product,
                  width: double.infinity,
                  height: double.infinity,
                  radius: AppRadius.md,
                  iconSize: 44,
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: AudienceBadge(audience: product.audience),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(product.brand.toUpperCase(), style: AppTextStyles.overline),
          Text(
            product.name.of(context),
            style: AppTextStyles.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.yellow),
              Text(' ${product.rating}', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatSum(context, product.price),
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).add(product.id);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(l10n.addedToCart),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                },
                child: CountBadge(
                  count: inCart,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Faol obunalar: qaysi ratsion, qaysi mahallar, qachongacha. Yo'q bo'lsa — hech narsa.
class _ActiveSubscriptions extends ConsumerWidget {
  const _ActiveSubscriptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref
        .watch(subscriptionsProvider)
        .where((s) => s.isActive)
        .toList();
    String t(String en, String uz, String ru) => Tr(en, uz, ru).of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in active)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                color: AppColors.primary,
                onTap: () => context.push(Routes.mySubscription(s.id)),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: AppColors.textOnPrimary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscriptionStatusInfo(context, s).$1.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$kitchenName · ${s.plan?.title.of(context) ?? s.planId}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.slots
                            .map((m) => '${m.label.of(context)} ${m.window}')
                            .join(' · '),
                      ),
                      Text(
                        '${t('Until', 'Gacha', 'До')} ${formatDate(context, s.endDate)} · ${s.address}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.recommendation),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(
              t(
                'Picked for you (based on your survey)',
                "Sizga mos tanlov (anketa bo'yicha)",
                'Подобрано для вас (по анкете)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
