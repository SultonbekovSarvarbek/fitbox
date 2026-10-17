import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import 'data/health_sync.dart';

/// Sozlamalar → Soat va qurilmalar: Health Connect / Apple Health ulanishi.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final w = ref.watch(healthSyncProvider);
    final sync = ref.read(healthSyncProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.devicesTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: sync.refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _Header(connected: w.connected),
            const SizedBox(height: AppSpacing.lg),
            if (w.availability == HealthAvailability.checking)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (w.availability == HealthAvailability.unsupported)
              _Notice(icon: Icons.block_rounded, text: l10n.healthUnsupported)
            else if (w.availability == HealthAvailability.needsInstall) ...[
              _Notice(
                icon: Icons.download_rounded,
                text: l10n.healthNeedsInstall,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.installHealthConnect,
                expanded: true,
                onPressed: () async {
                  await sync.install();
                  await sync.checkAvailability();
                },
              ),
            ] else if (!w.connected) ...[
              Text(l10n.healthWhatWeRead, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              for (final (icon, label) in [
                (Icons.directions_walk_rounded, l10n.steps),
                (Icons.favorite_rounded, l10n.heartRate),
                (Icons.bedtime_rounded, l10n.sleep),
                (Icons.local_fire_department_rounded, l10n.activeCalories),
                (Icons.monitor_weight_rounded, l10n.weightProgress),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(label, style: AppTextStyles.body),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _Notice(
                icon: Icons.lock_outline_rounded,
                text: l10n.healthReadOnly,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.connectWatch,
                icon: Icons.watch_rounded,
                expanded: true,
                onPressed: () async {
                  final ok = await sync.connect();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.healthDenied)));
                  }
                },
              ),
            ] else ...[
              _DataGrid(data: w),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      w.syncing
                          ? l10n.syncing
                          : w.lastSync == null
                          ? ''
                          : l10n.lastSync(DateFormat.Hm().format(w.lastSync!)),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ),
                  PrimaryButton(
                    label: l10n.refresh,
                    icon: Icons.sync_rounded,
                    variant: ButtonVariant.secondary,
                    compact: true,
                    onPressed: w.syncing ? null : sync.refresh,
                  ),
                ],
              ),
              if (!w.syncing && !w.hasAnyData) ...[
                const SizedBox(height: AppSpacing.md),
                _Notice(
                  icon: Icons.info_outline_rounded,
                  text: l10n.healthNoData,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _Notice(icon: Icons.watch_rounded, text: l10n.samsungHealthHint),
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: sync.disconnect,
                icon: const Icon(
                  Icons.link_off_rounded,
                  color: AppColors.error,
                ),
                label: Text(
                  l10n.disconnect,
                  style: AppTextStyles.title.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.primary : AppColors.surface,
            boxShadow: connected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 30,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.watch_rounded,
            size: 48,
            color: connected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          connected ? l10n.watchConnected : l10n.connectYourWatch,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.devicesSubtitle,
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DataGrid extends StatelessWidget {
  const _DataGrid({required this.data});

  final WatchData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String sleep(int? m) =>
        m == null ? '—' : '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
    final tiles = [
      (
        Icons.directions_walk_rounded,
        AppColors.primary,
        l10n.steps,
        data.steps == null
            ? '—'
            : NumberFormat.decimalPattern().format(data.steps),
        '',
      ),
      (
        Icons.favorite_rounded,
        AppColors.error,
        l10n.heartRate,
        '${data.heartRate ?? '—'}',
        l10n.bpm,
      ),
      (
        Icons.bedtime_rounded,
        AppColors.purple,
        l10n.sleep,
        sleep(data.sleepMinutes),
        l10n.hoursShort,
      ),
      (
        Icons.local_fire_department_rounded,
        AppColors.orange,
        l10n.activeCalories,
        '${data.activeKcal ?? '—'}',
        l10n.kcalLabel,
      ),
      (
        Icons.monitor_heart_rounded,
        AppColors.green,
        l10n.restingHeartRate,
        '${data.restingHeartRate ?? '—'}',
        l10n.bpm,
      ),
      (
        Icons.monitor_weight_rounded,
        AppColors.yellow,
        l10n.weightProgress,
        data.weightKg?.toStringAsFixed(1) ?? '—',
        l10n.kg,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        for (final (i, (icon, color, label, value, unit)) in tiles.indexed)
          FadeSlideIn(
            index: i,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 22),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: value,
                        style: AppTextStyles.h2,
                        children: [
                          if (unit.isNotEmpty && value != '—')
                            TextSpan(
                              text: ' $unit',
                              style: AppTextStyles.captionSecondary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.captionSecondary,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
        ],
      ),
    );
  }
}
