import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill_tabs.dart';
import '../market/subscribe_screen.dart' show formatDate;
import 'data/news_models.dart';

/// "Yangiliklar" tabi: ovqatlanish, sport, qo'shimchalar va retseptlar.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  /// 0 — hammasi, 1.. — kategoriyalar.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = NewsCategory.values;
    final category = _tab == 0 ? null : categories[_tab - 1];
    final items = newsSorted(category);
    final featured = category == null ? featuredNews : null;
    final rest = [
      for (final n in items)
        if (n.id != featured?.id) n,
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(l10n.tabNews, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [
              const Tr('All', 'Hammasi', 'Все').of(context),
              for (final c in categories) c.label.of(context),
            ],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                if (featured != null) ...[
                  _FeaturedCard(item: featured),
                  const SizedBox(height: AppSpacing.md),
                ],
                for (final n in rest) ...[
                  NewsTile(item: n),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String newsMeta(BuildContext context, NewsItem n) =>
    '${formatDate(context, n.date)} · ${context.l10n.minRead(n.minutes)}';

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final c = item.category.color;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push(Routes.newsItem(item.id)),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.withValues(alpha: 0.45), AppColors.surface],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.category.icon, size: 18, color: c),
                  const SizedBox(width: 6),
                  Text(
                    item.category.label.of(context).toUpperCase(),
                    style: AppTextStyles.overline.copyWith(color: c),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      const Tr('Top story', 'Asosiy', 'Главное').of(context),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(item.title.of(context), style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.summary.of(context),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                newsMeta(context, item),
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ro'yxatdagi bitta yangilik: kategoriya rangi, sarlavha, qisqa matn, sana.
class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final c = item.category.color;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.newsItem(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(item.category.icon, color: c),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.label.of(context).toUpperCase(),
                      style: AppTextStyles.overline.copyWith(color: c),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title.of(context),
                      style: AppTextStyles.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary.of(context),
                      style: AppTextStyles.captionSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      newsMeta(context, item),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
