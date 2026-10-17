import 'package:flutter/material.dart';
import '../../../core/assets/app_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../data/resources_models.dart';

/// Maqola / video qatori: rasm, kategoriya, nom, vaqt, yurakcha.
class ResourceTile extends ConsumerWidget {
  const ResourceTile({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isVideo = resource.kind == ResourceKind.video;
    final fav = ref.watch(favoritesProvider).contains(resource.id);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => context.push(Routes.resource(resource.id)),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              MediaPlaceholder(
                asset: AppImages.resource(resource.id),
                icon: isVideo
                    ? Icons.ondemand_video_rounded
                    : Icons.article_rounded,
                width: 88,
                height: 76,
                radius: AppRadius.md,
                iconSize: 28,
              ),
              if (isVideo)
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textOnPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.categoryOf(context).toUpperCase(),
                  style: AppTextStyles.overline,
                ),
                const SizedBox(height: 2),
                Text(
                  resource.titleOf(context),
                  style: AppTextStyles.title,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  isVideo
                      ? l10n.minutes(resource.minutes)
                      : l10n.minRead(resource.minutes),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(resource.id),
            icon: Icon(
              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
