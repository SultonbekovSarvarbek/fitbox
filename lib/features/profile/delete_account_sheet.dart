import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../core/app_reset.dart';
import '../../core/content/content_l10n.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/session.dart';
import '../setup/setup_profile.dart';

String _t(BuildContext c, String en, String uz, String ru) =>
    Tr(en, uz, ru).of(c);

/// Akkauntni o'chirish: nima yo'qolishini aytadi, tasdiq belgisi so'raydi.
/// Tasdiqlansa — ma'lumotlar o'chadi, holat tiklanadi va kirish ekraniga o'tiladi.
Future<void> showDeleteAccountSheet(BuildContext context, WidgetRef ref) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _DeleteSheet(),
  );
  if (ok != true) return;
  final prefs = ref.read(sharedPrefsProvider);
  final phone = Session.phone(prefs) ?? ref.read(userProvider).phone;
  // TODO(backend): `DELETE /me` — serverdagi akkaunt va ma'lumotlar ham o'chadi.
  await Session.deleteAccount(prefs, phone: phone.isEmpty ? null : phone);
  // Xotiradagi holat (profil, buyurtmalar, savat) ham yangidan boshlanadi.
  appResetEpoch.value++;
  appRouter.go(Routes.onboarding);
}

class _DeleteSheet extends StatefulWidget {
  const _DeleteSheet();

  @override
  State<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends State<_DeleteSheet> {
  var _understood = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      _t(
        context,
        'Your profile, survey answers and recommendations',
        "Profilingiz, anketa javoblari va tavsiyalar",
        'Ваш профиль, ответы анкеты и рекомендации',
      ),
      _t(
        context,
        'Order history and your cart',
        "Buyurtmalar tarixi va savat",
        'История заказов и корзина',
      ),
      _t(
        context,
        'Meal subscriptions — deliveries stop, no refund',
        "Ovqat obunalari — yetkazish to'xtaydi, pul qaytarilmaydi",
        'Подписки на питание — доставка прекратится, деньги не возвращаются',
      ),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _t(
                      context,
                      'Delete account?',
                      'Akkaunt o\'chirilsinmi?',
                      'Удалить аккаунт?',
                    ),
                    style: AppTextStyles.h2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _t(
                context,
                'This cannot be undone. The following will be deleted permanently:',
                "Buni qaytarib bo'lmaydi. Quyidagilar butunlay o'chiriladi:",
                'Это нельзя отменить. Навсегда будет удалено:',
              ),
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $i', style: AppTextStyles.body),
              ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => setState(() => _understood = !_understood),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Row(
                children: [
                  Checkbox(
                    value: _understood,
                    activeColor: AppColors.error,
                    onChanged: (v) => setState(() => _understood = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        'I understand this is permanent',
                        "Bu qaytarib bo'lmasligini tushundim",
                        'Я понимаю, что это необратимо',
                      ),
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: _t(
                context,
                'Delete forever',
                'Butunlay o\'chirish',
                'Удалить навсегда',
              ),
              variant: ButtonVariant.danger,
              expanded: true,
              onPressed: _understood
                  ? () => Navigator.pop(context, true)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: context.l10n.cancel,
              variant: ButtonVariant.secondary,
              expanded: true,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
