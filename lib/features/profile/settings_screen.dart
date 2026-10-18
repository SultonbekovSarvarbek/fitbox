import '../devices/data/health_sync.dart';
import '../../app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../progress/data/progress_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../ai/tts/voice_coach.dart';
import '../motivation/widgets/schedule_section.dart';

/// 6.1.4 Setting: til, bildirishnomalar, ovozli ko'rsatma.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _languages = {
    'uz': "O'zbekcha",
    'ru': 'Русский',
    'en': 'English',
  };

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.clearData, style: AppTextStyles.h3),
        content: Text(
          l10n.clearDataConfirm,
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: AppTextStyles.title),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.clearData,
              style: AppTextStyles.title.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    clearProgressData(ref);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.dataCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    Widget switchRow(
      IconData icon,
      String label,
      bool value,
      ValueChanged<bool> onChanged,
    ) => AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.title)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.textOnPrimary,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.devicesTitle.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            onTap: () => context.push(Routes.devices),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: ref.watch(healthSyncProvider).connected
                        ? AppColors.primary
                        : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.watch_rounded,
                    size: 22,
                    color: ref.watch(healthSyncProvider).connected
                        ? AppColors.textOnPrimary
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.devicesTitle, style: AppTextStyles.title),
                      Text(
                        ref.watch(healthSyncProvider).connected
                            ? l10n.watchConnected
                            : l10n.devicesSettingsHint,
                        style: AppTextStyles.captionSecondary,
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
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.language.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final l in supportedLocales)
                  ListTile(
                    onTap: () => ref.read(localeProvider.notifier).set(l),
                    title: Text(
                      _languages[l.languageCode]!,
                      style: AppTextStyles.title,
                    ),
                    trailing: l == locale
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: AppColors.textSecondary,
                          ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.notifications.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          const ScheduleSection(),
          const SizedBox(height: AppSpacing.sm),
          switchRow(
            Icons.record_voice_over_rounded,
            l10n.voiceGuide,
            ref.watch(voiceEnabledProvider),
            ref.read(voiceEnabledProvider.notifier).set,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.progress.toUpperCase(), style: AppTextStyles.overline),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            onTap: () => _confirmClear(context),
            child: Row(
              children: [
                const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.clearData,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        l10n.clearDataHint,
                        style: AppTextStyles.captionSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Forkout v1.0.0',
              style: AppTextStyles.captionSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
