import '../../core/widgets/primary_button.dart';
import '../../app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill_tabs.dart';
import '../resources/data/resources_models.dart';
import '../resources/widgets/resource_tile.dart';

/// 11.3 Favorite: All · Video · Article.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tab = 0; // 0 = all, 1 = video, 2 = article

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ids = ref.watch(favoritesProvider);
    final items = demoResources.where((r) {
      if (!ids.contains(r.id)) return false;
      return switch (_tab) {
        1 => r.kind == ResourceKind.video,
        2 => r.kind == ResourceKind.article,
        _ => true,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(l10n.tabFavorites, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.all, l10n.video, l10n.article],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 56,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.noFavorites,
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Bo'sh sahifada keyingi qadam — saqlash uchun narsa topish.
                        PrimaryButton(
                          label: l10n.browseArticles,
                          onPressed: () => context.go(Routes.resources),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg + AppSpacing.navOverlap,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => ResourceTile(resource: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
