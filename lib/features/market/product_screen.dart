import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import 'data/market_models.dart';
import 'data/product_info.dart';
import 'market_screen.dart' show ProductImage;

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Mahsulot sahifasi: nima uchun, qanday qabul qilinadi, tarkibi, qarshi ko'rsatmalar.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = products.where((e) => e.id == id).firstOrNull;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            _t(
              context,
              'Product not found',
              'Mahsulot topilmadi',
              'Товар не найден',
            ),
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }
    final info = productInfo[p.id];
    final cart = ref.watch(cartProvider);
    final qty = cart[p.id] ?? 0;
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.cart),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          ProductImage(
            product: p,
            width: double.infinity,
            height: 260,
            radius: AppRadius.lg,
            iconSize: 96,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(p.brand.toUpperCase(), style: AppTextStyles.overline),
          Text(p.name.of(context), style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.yellow),
              Text(' ${p.rating}', style: AppTextStyles.title),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  p.size.of(context),
                  style: AppTextStyles.captionSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(p.description.of(context), style: AppTextStyles.body),
          if (info != null) ...[
            _Section(
              icon: Icons.flag_rounded,
              title: _t(context, "What it's for", 'Nima uchun', 'Для чего'),
              child: _Bullets(
                items: [for (final b in info.benefits) b.of(context)],
                icon: Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
            ),
            _Section(
              icon: Icons.menu_book_rounded,
              title: _t(
                context,
                'How to use',
                'Qabul qilish usuli',
                'Способ применения',
              ),
              child: _Steps(
                items: [for (final s in info.howToUse) s.of(context)],
              ),
            ),
            _Section(
              icon: Icons.science_outlined,
              title: _t(context, 'Composition', 'Tarkibi', 'Состав и ценность'),
              child: Column(
                children: [
                  for (var i = 0; i < info.facts.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.facts[i].$1.of(context),
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                          Text(
                            info.facts[i].$2.of(context),
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _Section(
              icon: Icons.warning_amber_rounded,
              title: _t(
                context,
                'Contraindications',
                "Qarshi ko'rsatmalar",
                'Противопоказания',
              ),
              accent: AppColors.orange,
              child: _Bullets(
                items: [for (final c in info.contraindications) c.of(context)],
                icon: Icons.error_outline_rounded,
                color: AppColors.orange,
              ),
            ),
            if (info.storage != null)
              _Section(
                icon: Icons.inventory_2_outlined,
                title: _t(context, 'Storage', 'Saqlash', 'Хранение'),
                child: Text(
                  info.storage!.of(context),
                  style: AppTextStyles.body,
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  supplementDisclaimer.of(context),
                  style: AppTextStyles.captionSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _t(
              context,
              'Demo: composition and instructions are examples. For a real product always follow the manufacturer’s label.',
              "Demo: tarkib va ko'rsatmalar namunaviy. Haqiqiy mahsulotda doim ishlab chiqaruvchi yorlig'iga amal qiling.",
              'Демо: состав и инструкции — примеры. Для реального товара всегда следуйте этикетке производителя.',
            ),
            style: AppTextStyles.caption.copyWith(color: AppColors.orange),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatSum(context, p.price),
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (qty == 0)
                PrimaryButton(
                  label: context.l10n.addToCart,
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(cartProvider.notifier).add(p.id);
                  },
                )
              else ...[
                _Stepper(
                  qty: qty,
                  onMinus: () => ref.read(cartProvider.notifier).remove(p.id),
                  onPlus: () => ref.read(cartProvider.notifier).add(p.id),
                ),
                const SizedBox(width: AppSpacing.sm),
                PrimaryButton(
                  label: context.l10n.cart,
                  onPressed: () => context.push(Routes.cart),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.accent,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: accent == null
              ? null
              : Border.all(color: accent!.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: accent ?? AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({
    required this.items,
    required this.icon,
    required this.color,
  });

  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final t in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(t, style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(items[i], style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: '−',
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded),
          ),
          Text('$qty', style: AppTextStyles.title),
          IconButton(
            tooltip: '+',
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
