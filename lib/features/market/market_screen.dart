import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/audience.dart';
import '../../core/widgets/audience_switch.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/section_title.dart';
import '../nutrition/data/nutrition_goals.dart';
import '../setup/setup_profile.dart';
import 'data/market_models.dart';
import 'data/subscription_models.dart';
import 'subscribe_screen.dart' show formatDate;
import 'subscription_detail_screen.dart' show subscriptionStatusInfo;
import 'widgets/checkout_sheet.dart';

part 'market_screen_widgets.dart';

/// Do'kon: ovqat yetkazib berish + sportpit.
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.market, style: AppTextStyles.h2),
        actions: [
          IconButton(
            tooltip: l10n.myOrders,
            onPressed: () => showOrdersSheet(context),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
          IconButton(
            onPressed: () => context.push(Routes.cart),
            icon: CountBadge(
              count: ref.watch(cartCountProvider),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.mealDelivery, l10n.sportNutrition],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _DemoBanner(),
          Expanded(child: _tab == 0 ? const _DeliveryTab() : const _StoreTab()),
        ],
      ),
    );
  }
}

void showOrdersSheet(BuildContext context) {
  final l10n = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final orders = ref.watch(ordersProvider);
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.myOrders, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            if (orders.isEmpty)
              Text(l10n.noOrdersYet, style: AppTextStyles.bodySecondary),
            for (final o in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  color: AppColors.surfaceLight,
                  child: Row(
                    children: [
                      Icon(o.payment.icon, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.title,
                              style: AppTextStyles.title,
                              maxLines: 2,
                            ),
                            Text(
                              '${o.id} · ${l10n.orderStatusDemo}',
                              style: AppTextStyles.captionSecondary,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatSum(context, o.total),
                        style: AppTextStyles.title,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

List<Widget> marketActions(BuildContext context, WidgetRef ref) {
  final l10n = context.l10n;
  return [
    IconButton(
      tooltip: l10n.myOrders,
      onPressed: () => showOrdersSheet(context),
      icon: const Icon(Icons.receipt_long_rounded),
    ),
    IconButton(
      onPressed: () => context.push(Routes.cart),
      icon: CountBadge(
        count: ref.watch(cartCountProvider),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    ),
    const SizedBox(width: AppSpacing.sm),
  ];
}

/// Pastki menyudagi "Do'kon": sportpit (protein, kreatin...) — darrov sotib olinadi.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(l10n.tabShop, style: AppTextStyles.h2),
        actions: marketActions(context, ref),
      ),
      body: Column(
        children: [
          const _DemoBanner(),
          const Expanded(child: _StoreTab()),
        ],
      ),
    );
  }
}

/// Pastki menyudagi "Obuna": kuniga 3 mahal (ertalab, tushlik, kechqurun) kuryer yetkazadi.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(l10n.tabSubscription, style: AppTextStyles.h2),
        actions: marketActions(context, ref),
      ),
      body: Column(
        children: [
          const _DemoBanner(),
          const Expanded(child: _DeliveryTab()),
        ],
      ),
    );
  }
}

/// Mahsulot rasmi: surat bo'lsa oq fonda (qadoq suratlari oq fonli), aks holda ikonka.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.width,
    this.height,
    required this.radius,
    required this.iconSize,
  });

  final Product product;
  final double? width;
  final double? height;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final image = product.image;
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: image != null ? AppColors.white : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: image != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(image, fit: BoxFit.contain),
            )
          : Icon(
              categoryIcon(product.category),
              size: iconSize,
              color: AppColors.primary,
            ),
    );
  }
}

/// Savat.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart)),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.cartEmpty, style: AppTextStyles.bodySecondary),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final e in cart.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          ProductImage(
                            product: productById(e.key),
                            width: 52,
                            height: 52,
                            radius: AppRadius.md,
                            iconSize: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productById(e.key).name.of(context),
                                  style: AppTextStyles.title,
                                  maxLines: 2,
                                ),
                                Text(
                                  formatSum(
                                    context,
                                    productById(e.key).price * e.value,
                                  ),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                ref.read(cartProvider.notifier).remove(e.key),
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                          ),
                          Text('${e.value}', style: AppTextStyles.h3),
                          IconButton(
                            onPressed: () =>
                                ref.read(cartProvider.notifier).add(e.key),
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _BuyBar(
                  total: total,
                  label: l10n.orderFor(formatSum(context, total)),
                  onTap: () async {
                    final ok = await showCheckout(
                      context,
                      ref,
                      title: l10n.sportOrderTitle(ref.read(cartCountProvider)),
                      total: total,
                    );
                    if (ok) ref.read(cartProvider.notifier).clear();
                  },
                ),
              ),
            ),
    );
  }
}
