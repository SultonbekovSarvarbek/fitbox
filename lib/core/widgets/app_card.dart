import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Qorong'i yumaloq karta — rasmlardagi barcha bloklarning asosi.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surface,
    this.radius = AppRadius.lg,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Ikon + matnli qorong'i "chip" ("Rewards", "Journal", "45 min").
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color = AppColors.surface,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  /// O'qilmaganlar soni — 0 bo'lsa ko'rinmaydi.
  final int badge;

  @override
  Widget build(BuildContext context) {
    return CountBadge(count: badge, child: _chip());
  }

  Widget _chip() {
    return Material(
      color: color,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.title.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lime yumaloq ikon tugma (orqaga, sevimli va h.k.).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background = AppColors.surface,
    this.foreground = AppColors.textPrimary,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foreground, size: size * 0.5),
        ),
      ),
    );
  }
}

/// Burchakdagi qizil son belgisi (yangi xabarlar). `count == 0` — yashirin.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: AnimatedScale(
            scale: count > 0 ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
