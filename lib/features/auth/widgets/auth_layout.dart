import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/language_button.dart';

/// Login / Sign Up / Forgot password uchun umumiy karkas (qora fon, chapga tekislangan).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.action,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageButton(),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title.toUpperCase(), style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle, style: AppTextStyles.bodySecondary),
              const SizedBox(height: AppSpacing.xl),
              for (final f in fields) ...[
                f,
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.sm),
              action,
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Hisobingiz yo'qmi? Ro'yxatdan o'tish" ko'rinishidagi qator.
class AuthSwitchRow extends StatelessWidget {
  const AuthSwitchRow({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: AppTextStyles.bodySecondary),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
