import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// uz / ru / en almashtirish tugmasi.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  static const _names = {'uz': "O'zbekcha", 'ru': 'Русский', 'en': 'English'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    return PopupMenuButton<Locale>(
      tooltip: context.l10n.language,
      color: AppColors.surface,
      onSelected: ref.read(localeProvider.notifier).set,
      itemBuilder: (_) => [
        for (final l in supportedLocales)
          PopupMenuItem(
            value: l,
            child: Text(
              _names[l.languageCode]!,
              style: AppTextStyles.body.copyWith(
                color: l == current ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: AppColors.primary, size: 20),
            const SizedBox(width: 4),
            Text(
              current.languageCode.toUpperCase(),
              style: AppTextStyles.title,
            ),
          ],
        ),
      ),
    );
  }
}
