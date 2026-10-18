import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/audience.dart';
import '../../core/widgets/audience_switch.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../market/data/market_models.dart';
import '../market/market_screen.dart' show ProductImage;
import 'data/news_models.dart';
import 'news_screen.dart' show NewsTile, newsMeta;

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Maqolani o'qish: sarlavha, kirish, matn, bog'liq mahsulot yoki obuna, "Yana o'qing".
class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final item = newsById(id);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            context.l10n.notFound,
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }
    final c = item.category.color;
    final product = item.productId == null
        ? null
        : products.where((p) => p.id == item.productId).firstOrNull;
    final related = relatedNews(item);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Row(
            children: [
              Icon(item.category.icon, size: 18, color: c),
              const SizedBox(width: 6),
              Text(
                item.category.label.of(context).toUpperCase(),
                style: AppTextStyles.overline.copyWith(color: c),
              ),
              if (item.audience != Audience.everyone) ...[
                const SizedBox(width: 8),
                AudienceBadge(audience: item.audience),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.title.of(context), style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            newsMeta(context, item),
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            item.summary.of(context),
            style: AppTextStyles.title.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          for (final p in item.body)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                p.of(context),
                style: AppTextStyles.body.copyWith(height: 1.6),
              ),
            ),
          if (product != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              onTap: () => context.push(Routes.product(product.id)),
              child: Row(
                children: [
                  ProductImage(
                    product: product,
                    width: 64,
                    height: 64,
                    radius: AppRadius.md,
                    iconSize: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(context, 'In the shop', "Do'konda", 'В магазине'),
                          style: AppTextStyles.overline,
                        ),
                        Text(
                          product.name.of(context),
                          style: AppTextStyles.title,
                          maxLines: 2,
                        ),
                        Text(
                          formatSum(context, product.price),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
          if (item.toSubscription) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              color: AppColors.primary,
              onTap: () => context.go(Routes.subscription),
              child: Row(
                children: [
                  const Icon(
                    Icons.soup_kitchen_rounded,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'Meal programs from Forkout Kitchen',
                        "Forkout Kitchen ovqat ratsionlari",
                        'Программы питания Forkout Kitchen',
                      ),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.textOnPrimary,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            _t(
              context,
              'General information, not medical advice. If you have a health condition, talk to a doctor.',
              "Umumiy ma'lumot, tibbiy maslahat emas. Sog'liq muammolari bo'lsa, shifokor bilan maslahatlashing.",
              'Общая информация, а не медицинский совет. Если у вас есть заболевания, проконсультируйтесь с врачом.',
            ),
            style: AppTextStyles.captionSecondary,
          ),
          if (related.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              _t(context, 'Read next', "Yana o'qing", 'Читайте также'),
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final n in related) ...[
              NewsTile(item: n),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}
