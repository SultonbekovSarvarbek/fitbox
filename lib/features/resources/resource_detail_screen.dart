import 'package:flutter/material.dart';
import '../../core/assets/app_images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import 'data/resources_models.dart';

/// Maqola o'qish / video ko'rish ekrani.
class ResourceDetailScreen extends ConsumerWidget {
  const ResourceDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = resourceById(id);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notFound)),
      );
    }
    final isVideo = r.kind == ResourceKind.video;
    final fav = ref.watch(favoritesProvider).contains(r.id);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              ImageCard(
                motion: true,
                height: 300,
                asset: AppImages.resource(r.id),
                radius: 0,
                icon: isVideo
                    ? Icons.ondemand_video_rounded
                    : Icons.article_rounded,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    // TODO(video): video_player / chewie bilan haqiqiy pleyer.
                    if (isVideo)
                      const Center(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 40,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      r.categoryOf(context).toUpperCase(),
                      style: AppTextStyles.overline,
                    ),
                    Text(r.titleOf(context), style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isVideo
                          ? l10n.minutes(r.minutes)
                          : l10n.minRead(r.minutes),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: r.bodyOf(context).isEmpty
                    ? Text(l10n.comingSoon, style: AppTextStyles.bodySecondary)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final p in r.bodyOf(context))
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: Text(
                                p,
                                style: AppTextStyles.body.copyWith(height: 1.6),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    background: AppColors.black.withValues(alpha: 0.5),
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  CircleIconButton(
                    icon: fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    background: fav
                        ? AppColors.primary
                        : AppColors.black.withValues(alpha: 0.5),
                    foreground: fav
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                    onTap: () =>
                        ref.read(favoritesProvider.notifier).toggle(r.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
