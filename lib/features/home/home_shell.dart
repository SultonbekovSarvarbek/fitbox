import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// 11. Bottom Navigation — qora panel: Asosiy · Do'kon · Obuna · Yangiliklar · Profil.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded),
    (Icons.storefront_outlined, Icons.storefront_rounded),
    (Icons.local_shipping_outlined, Icons.local_shipping_rounded),
    (Icons.newspaper_outlined, Icons.newspaper_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  /// Ikon ostida nom — har bir tab nima ekani darhol tushunarli bo'lsin.
  Widget _tab(int i, String label) {
    final (icon, activeIcon) = _items[i];
    final active = i == shell.currentIndex;
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: () => shell.goBranch(i, initialLocation: active),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.surfaceLight : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(active ? activeIcon : icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _tab(0, l10n.tabHome),
            _tab(1, l10n.tabShop),
            _tab(2, l10n.tabSubscription),
            _tab(3, l10n.tabNews),
            _tab(4, l10n.tabProfile),
          ],
        ),
      ),
    );
  }
}
