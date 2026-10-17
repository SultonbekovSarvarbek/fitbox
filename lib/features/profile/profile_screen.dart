import '../auth/session.dart';
import 'package:flutter/material.dart';
import 'widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/content/content_l10n.dart';
import '../auth/phone.dart';
import '../market/data/market_models.dart' show kitchenName;
import '../market/data/subscription_models.dart';
import '../market/market_screen.dart' show showOrdersSheet;
import '../market/subscription_detail_screen.dart' show subscriptionStatusInfo;
import '../setup/setup_profile.dart';
import 'delete_account_sheet.dart';

/// 6.1 Profile — design/2.png (trener profili uslubida):
/// avatar, ism, statistika qatori, menyu qatorlari.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.logOutConfirm,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 54),
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Text(l10n.cancel, style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 54),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      l10n.logOut,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    await Session.signOut(ref.read(sharedPrefsProvider));
    if (context.mounted) context.go(Routes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(userProvider);
    final phone = Session.phone(ref.watch(sharedPrefsProvider)) ?? user.phone;
    final live = ref
        .watch(subscriptionsProvider)
        .where((s) => s.isLive)
        .firstOrNull;
    String t(String en, String uz, String ru) => Tr(en, uz, ru).of(context);

    Widget row(
      IconData icon,
      String label,
      VoidCallback onTap, {
      Color? color,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color ?? AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.title.copyWith(color: color),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(text.toUpperCase(), style: AppTextStyles.overline),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(child: UserAvatar(editable: true, ring: true)),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName
                  : user.displayName.isNotEmpty
                  ? user.displayName
                  : l10n.friend,
              style: AppTextStyles.h2,
            ),
          ),
          if (phone.isNotEmpty)
            Center(
              child: Text(
                formatPhone(phone),
                style: AppTextStyles.captionSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                _Stat(
                  value: '${user.weightKg} ${l10n.kg}',
                  label: l10n.weightProgress,
                ),
                _divider,
                _Stat(value: '${user.age}', label: l10n.ageLabel),
                _divider,
                _Stat(
                  value: '${user.heightCm} ${l10n.cm}',
                  label: l10n.heightLabel,
                ),
              ],
            ),
          ),
          heading(
            t('Meal subscription', 'Ovqat obunasi', 'Подписка на питание'),
          ),
          if (live != null)
            _SubscriptionTile(sub: live)
          else
            row(
              Icons.local_shipping_outlined,
              t(
                'No subscription — pick one',
                "Obuna yo'q — tanlang",
                'Нет подписки — выбрать',
              ),
              () => context.go(Routes.subscription),
            ),
          heading(t('Account', 'Akkaunt', 'Аккаунт')),
          row(
            Icons.person_outline_rounded,
            l10n.editProfile,
            () => context.push(Routes.editProfile),
          ),
          row(
            Icons.auto_awesome_rounded,
            t('My recommendations', 'Mening tavsiyalarim', 'Мои рекомендации'),
            () => context.push(Routes.recommendation),
          ),
          row(
            Icons.receipt_long_rounded,
            l10n.myOrders,
            () => showOrdersSheet(context),
          ),
          heading(l10n.settings),
          row(
            Icons.notifications_none_rounded,
            l10n.notifications,
            () => context.push(Routes.notifications),
          ),
          row(
            Icons.settings_outlined,
            l10n.settings,
            () => context.push(Routes.settings),
          ),
          row(
            Icons.help_outline_rounded,
            l10n.help,
            () => context.push(Routes.support),
          ),
          const SizedBox(height: AppSpacing.md),
          row(Icons.logout_rounded, l10n.logOut, () => _logout(context, ref)),
          row(
            Icons.delete_forever_rounded,
            t('Delete account', 'Akkauntni o\'chirish', 'Удалить аккаунт'),
            () => showDeleteAccountSheet(context, ref),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  static const _divider = SizedBox(
    height: 32,
    child: VerticalDivider(color: AppColors.border, width: 1),
  );
}

/// Profildagi obuna kartasi: holat + ratsion; bosilsa — boshqarish ekrani.
class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final (status, color) = subscriptionStatusInfo(context, sub);
    return AppCard(
      onTap: () => context.push(Routes.mySubscription(sub.id)),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$kitchenName · ${sub.plan?.title.of(context) ?? ''}',
                  style: AppTextStyles.title,
                ),
                Text(
                  status,
                  style: AppTextStyles.caption.copyWith(color: color),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h3),
          Text(label, style: AppTextStyles.captionSecondary),
        ],
      ),
    );
  }
}
