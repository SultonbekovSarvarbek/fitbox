import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../workout/data/workout_models.dart';
import '../data/motivation_providers.dart';
import 'achievements_sheet.dart';
import 'plan_picker.dart';

/// Home tepasidagi "Bugungi vazifa": nima qilish kerak, seriya, qolgan vaqt, daraja.
/// Maqsad — foydalanuvchini har kuni mashg'ulotga undash.
class MissionCard extends ConsumerWidget {
  const MissionCard({super.key, required this.routine});

  /// Bugungi tavsiya etilgan mashg'ulot.
  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final d = ref.watch(disciplineProvider);
    final schedule = ref.watch(scheduleProvider);
    final collapsed = ref.watch(missionCollapsedProvider);
    final now = DateTime.now();
    final hoursLeft = 24 - now.hour - (now.minute > 0 ? 1 : 0);
    // Bugun uchun o'zi tanlagan vazifa (yoki avtomatik tavsiya).
    final mission = resolveMission(
      context,
      ref,
      schedule.plans[now.weekday],
      routine,
    );

    final (icon, title, subtitle, accent) = switch (d.state) {
      MissionState.todo => (
        mission.icon,
        mission.title,
        mission.subtitle,
        AppColors.primary,
      ),
      MissionState.done => (
        Icons.check_circle_rounded,
        l10n.missionDone,
        l10n.missionDoneHint,
        AppColors.green,
      ),
      MissionState.rest => (
        Icons.self_improvement_rounded,
        l10n.missionRest,
        l10n.missionRestHint,
        AppColors.purple,
      ),
    };

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.todaysMission.toUpperCase(),
                style: AppTextStyles.overline,
              ),
              const Spacer(),
              _StreakChip(
                streak: d.streak,
                alive: d.state != MissionState.todo,
              ),
              // Vazifani o'zi belgilash.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showPlanPicker(context, ref, now.weekday, routine),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Yig'ish / ochish.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(missionCollapsedProvider.notifier).toggle();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: AnimatedRotation(
                    turns: collapsed ? 0.5 : 0,
                    duration: AppMotion.medium,
                    child: const Icon(
                      Icons.expand_less_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.captionSecondary),
                  ],
                ),
              ),
              // Yig'ilgan holatda ham bir bosishda boshlash mumkin.
              if (collapsed && d.state == MissionState.todo)
                GestureDetector(
                  onTap: () => context.push(mission.route),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
            ],
          ),
          // Yig'ilganda faqat sarlavha qatori qoladi.
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.curve,
            alignment: Alignment.topCenter,
            child: collapsed
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (d.state == MissionState.todo) ...[
                        const SizedBox(height: AppSpacing.sm),
                        // Bosim: seriya xavf ostida + kun tugashiga qolgan vaqt.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.hourglass_bottom_rounded,
                                size: 16,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  d.streak > 0
                                      ? l10n.missionStreakAtRisk(
                                          d.streak,
                                          hoursLeft,
                                        )
                                      : l10n.missionHoursLeft(hoursLeft),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: l10n.startNow,
                          icon: Icons.play_arrow_rounded,
                          expanded: true,
                          onPressed: () => context.push(mission.route),
                        ),
                      ],
                      if (d.state == MissionState.rest) ...[
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: l10n.missionLightRun,
                          icon: Icons.directions_walk_rounded,
                          variant: ButtonVariant.outline,
                          expanded: true,
                          onPressed: () => context.push(Routes.run),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _WeekDots(),
                      const SizedBox(height: AppSpacing.md),
                      // Daraja va XP — bosilsa yutuqlar.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showAchievements(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                l10n.levelShort(d.level),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: d.levelProgress),
                                  duration: AppMotion.slow,
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, _) => LinearProgressIndicator(
                                    value: v,
                                    minHeight: 6,
                                    color: AppColors.primary,
                                    backgroundColor: AppColors.surfaceLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${d.xp} / ${d.nextLevelXp} XP',
                              style: AppTextStyles.captionSecondary,
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      if (!schedule.enabled) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1, color: AppColors.border),
                        InkWell(
                          onTap: () => context.push(Routes.settings),
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    l10n.setScheduleCta,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak, required this.alive});

  final int streak;

  /// Bugun seriya himoyalangan (bajarilgan yoki dam olish kuni).
  final bool alive;

  @override
  Widget build(BuildContext context) {
    final color = alive ? AppColors.orange : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text('$streak', style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Shu hafta: Du..Ya — bajarilgan (yashil), reja (ramka), dam olish (xira).
class _WeekDots extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schedule = ref.watch(scheduleProvider);
    final d = ref.watch(disciplineProvider);
    final done = ref.watch(workoutDaysProvider);
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final labels = weekdayShortLabels(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(l10n.thisWeek, style: AppTextStyles.captionSecondary),
            const Spacer(),
            Text(
              l10n.weekProgress(d.weekDone, d.weekPlanned),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 7; i++)
              Builder(
                builder: (_) {
                  final day = monday.add(Duration(days: i));
                  final isDone = done.contains(day);
                  final planned = schedule.isTrainingDay(day);
                  final isToday = i == today.weekday - 1;
                  return Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.primary
                              : AppColors.surfaceLight.withValues(
                                  alpha: planned ? 1 : 0.4,
                                ),
                          border: isToday && !isDone
                              ? Border.all(color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.textOnPrimary,
                              )
                            : planned
                            ? const Icon(
                                Icons.fitness_center_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: AppTextStyles.captionSecondary.copyWith(
                          color: isToday ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Du, Se, Ch… — tanlangan tilda (intl orqali).
List<String> weekdayShortLabels(BuildContext context) {
  final names = MaterialLocalizations.of(context).narrowWeekdays;
  // narrowWeekdays yakshanbadan boshlanadi.
  return [for (var i = 1; i <= 7; i++) names[i % 7]];
}
