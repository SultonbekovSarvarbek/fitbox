import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'animations.dart';

enum ButtonVariant {
  /// Neon-lime fon, qora matn ("SIGN IN", "Next").
  primary,

  /// Qorong'i fon, oq matn ("SIGN UP", "Previous").
  secondary,

  /// Shaffof fon, chegara.
  outline,

  /// Qaytarib bo'lmaydigan amal (akkauntni o'chirish): qizil fon.
  danger,
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.expanded = false,
    this.icon,
    this.compact = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool expanded;
  final IconData? icon;
  final bool compact;

  /// Kutish: tugma bosilmaydi, matn o'rnida aylana.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      ButtonVariant.primary => (
        AppColors.primary,
        AppColors.textOnPrimary,
        null,
      ),
      ButtonVariant.secondary => (
        AppColors.surfaceLight,
        AppColors.textPrimary,
        null,
      ),
      ButtonVariant.outline => (
        Colors.transparent,
        AppColors.textPrimary,
        const BorderSide(color: AppColors.border),
      ),
      ButtonVariant.danger => (AppColors.error, Colors.white, null),
    };

    // Uzun tarjimalar (ru/uz) tugmaga sig'masa — kichrayadi, ikki qatorga tushmaydi.
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        style: AppTextStyles.button.copyWith(color: fg),
      ),
    );
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Kutish paytida tugma o'chiq ko'rinmasin.
        disabledBackgroundColor: loading ? bg : bg.withValues(alpha: 0.4),
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        side: border,
        minimumSize: Size(0, compact ? 40 : 54),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.md : AppSpacing.lg,
        ),
        shape: const StadiumBorder(),
      ),
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
            )
          : icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
                text,
              ],
            ),
    );

    return PressableScale(
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
