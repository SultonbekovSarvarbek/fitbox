import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../data/motivation_providers.dart';
import '../data/reminder_service.dart';
import 'mission_card.dart';
import 'plan_picker.dart';

/// Sozlamalar: mashg'ulot kunlari, eslatma vaqti va eslatmalarni yoqish.
class ScheduleSection extends ConsumerWidget {
  const ScheduleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);
    final labels = weekdayShortLabels(context);
    final time = TimeOfDay(hour: s.hour, minute: s.minute);

    Future<void> toggle(bool on) async {
      if (on) {
        final granted = await ReminderService.instance.requestPermission();
        if (!granted && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.notificationsDenied)));
          return;
        }
      }
      notifier.set(s.copyWith(enabled: on));
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alarm_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.workoutReminders, style: AppTextStyles.title),
                    Text(
                      l10n.remindersHint,
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.enabled,
                onChanged: toggle,
                activeTrackColor: AppColors.primary,
                activeThumbColor: AppColors.textOnPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.trainingDays, style: AppTextStyles.captionSecondary),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var wd = 1; wd <= 7; wd++)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.toggleDay(wd);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.weekdays.contains(wd)
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                    ),
                    child: Text(
                      labels[wd - 1],
                      style: AppTextStyles.title.copyWith(
                        color: s.weekdays.contains(wd)
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Har mashg'ulot kuni uchun vazifa — bosib o'zgartiriladi.
          Text(l10n.dayMissions, style: AppTextStyles.captionSecondary),
          const SizedBox(height: 4),
          for (final wd in (s.weekdays.toList()..sort()))
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () => showPlanPicker(
                context,
                ref,
                wd,
                ref.read(autoRoutineProvider(wd)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 104,
                      child: Text(
                        weekdayName(context, wd),
                        style: AppTextStyles.title,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        s.plans[wd] == null
                            ? l10n.missionAuto
                            : resolveMission(
                                context,
                                ref,
                                s.plans[wd],
                                ref.watch(autoRoutineProvider(wd)),
                              ).title,
                        style: AppTextStyles.body.copyWith(
                          color: s.plans[wd] == null
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: AppSpacing.lg, color: AppColors.border),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
                builder: (ctx, child) => MediaQuery(
                  data: MediaQuery.of(
                    ctx,
                  ).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
              );
              if (picked != null) {
                notifier.set(
                  s.copyWith(hour: picked.hour, minute: picked.minute),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(l10n.reminderTime, style: AppTextStyles.title),
                  const Spacer(),
                  Text(
                    '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Text(
            l10n.streakSaverHint(ReminderService.saverHour(s)),
            style: AppTextStyles.captionSecondary,
          ),
        ],
      ),
    );
  }
}
