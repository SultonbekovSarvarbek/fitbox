import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';

/// O'qilmagan bildirishnomalar soni (qo'ng'iroqcha belgisi uchun).
/// Hozircha ro'yxat statik (5 ta) — sahifa ochilganda o'qilgan deb belgilanadi.
/// TODO(push): server/FCM'dan kelgan haqiqiy bildirishnomalar.
final unreadNotificationsProvider = StateProvider<int>((ref) => 0);

const _seenKey = 'notifications_seen';

/// 6.2 Notifications: 6.2.1 Workout Reminders · 6.2.2 System Notifications.
/// TODO(push): flutter_local_notifications + FCM.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unreadNotificationsProvider.notifier).state = 0;
      ref.read(sharedPrefsProvider).setBool(_seenKey, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // TODO(push): server/FCM'dan kelgan haqiqiy bildirishnomalar. Hozircha bo'sh.
    const reminders = <(IconData, String, String)>[];
    const system = <(IconData, String, String)>[];
    final items = _tab == 0 ? reminders : system;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.workoutReminders, l10n.systemNotifications],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.noNotifications,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final (icon, text, time) = items[i];
                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: i == 0
                              ? AppColors.primary
                              : AppColors.surfaceLight,
                          child: Icon(
                            icon,
                            color: i == 0
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(text, style: AppTextStyles.body)),
                        const SizedBox(width: AppSpacing.sm),
                        Text(time, style: AppTextStyles.captionSecondary),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
