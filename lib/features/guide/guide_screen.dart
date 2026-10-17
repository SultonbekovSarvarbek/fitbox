import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import 'data/guide_content.dart';

/// To'liq foydalanish qo'llanmasi: har bo'lim — nima uchun va qanday ishlatiladi.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userGuide)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appMission.title.of(context),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  appMission.summary.of(context),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final t in guideTopics)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  // ExpansionTile'ning ichki chiziqlarini olib tashlash.
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.textSecondary,
                    leading: Icon(t.icon, color: AppColors.primary),
                    title: Text(
                      t.title.of(context),
                      style: AppTextStyles.title,
                    ),
                    subtitle: Text(
                      t.summary.of(context),
                      style: AppTextStyles.captionSecondary,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, step) in t.steps.indexed)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  step.of(context),
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (t.route != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => t.route!.startsWith(Routes.home)
                                ? context.go(t.route!)
                                : context.push(t.route!),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              l10n.openSection,
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.tour),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              shape: const StadiumBorder(),
              side: const BorderSide(color: AppColors.border),
            ),
            icon: const Icon(Icons.slideshow_rounded, color: AppColors.primary),
            label: Text(l10n.replayTour, style: AppTextStyles.title),
          ),
        ],
      ),
    );
  }
}
