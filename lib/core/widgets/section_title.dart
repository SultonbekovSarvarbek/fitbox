import 'package:flutter/material.dart';

import '../locale/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "Daily Program ........ See all" sarlavhasi.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    this.action,
  });

  final String title;
  final VoidCallback? onSeeAll;

  /// "See all" o'rniga boshqa matn (masalan "Edit plan").
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.h3)),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(
                  action ?? context.l10n.seeAll,
                  style: AppTextStyles.captionSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
