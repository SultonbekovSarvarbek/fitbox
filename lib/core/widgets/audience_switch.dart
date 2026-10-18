import 'package:flutter/material.dart';

import '../audience.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// «Все / Мужчинам / Женщинам» — одинаковый переключатель для магазина, программ питания и новостей.
class AudienceSwitch extends StatelessWidget {
  const AudienceSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AudienceFilter value;
  final ValueChanged<AudienceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            for (final f in AudienceFilter.values)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: f == value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        audienceFilterNames[f]!.of(context),
                        style: AppTextStyles.title.copyWith(
                          color: f == value
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Маленькая метка на карточке: «Мужчинам» / «Женщинам». Для «всех» — ничего.
class AudienceBadge extends StatelessWidget {
  const AudienceBadge({super.key, required this.audience});

  final Audience audience;

  @override
  Widget build(BuildContext context) {
    if (audience == Audience.everyone) return const SizedBox.shrink();
    final women = audience == Audience.women;
    final color = women ? const Color(0xFFFF6FA8) : const Color(0xFF5AA9FF);
    final text =
        audienceFilterNames[women ? AudienceFilter.women : AudienceFilter.men]!
            .of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
