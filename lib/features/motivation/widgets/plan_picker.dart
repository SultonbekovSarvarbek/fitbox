import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bodybuilding/data/bb_models.dart';
import '../../workout/data/workout_models.dart';
import '../data/discipline.dart';
import '../data/motivation_providers.dart';

/// Ekranda ko'rsatiladigan vazifa: nomi, izohi va qayerga olib boradi.
class ResolvedMission {
  const ResolvedMission({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

/// Vazifa kalitidan ([MissionPlan]) aniq vazifa. `null` — avtomatik ([auto]).
ResolvedMission resolveMission(
  BuildContext context,
  WidgetRef ref,
  String? plan,
  Routine auto,
) {
  final l10n = context.l10n;
  ResolvedMission ofRoutine(Routine r) => ResolvedMission(
    icon: Icons.bolt_rounded,
    title: r.titleOf(context),
    subtitle: '${l10n.minutes(r.minutes)} · ${l10n.kcal(r.kcal)}',
    route: Routes.routine(r.id),
  );

  if (plan == MissionPlan.bodybuilding) {
    final program = programById(ref.watch(bbProgramIdProvider));
    final dayIndex = ref.watch(bbNextDayProvider);
    final day = program.days[dayIndex];
    final sets = day.items.fold(0, (s, p) => s + p.sets);
    return ResolvedMission(
      icon: Icons.fitness_center_rounded,
      title: '${l10n.bodybuilding} · ${day.name.of(context)}',
      subtitle:
          '${l10n.exercisesCount(day.items.length)} · ${l10n.setsCount(sets)}',
      route: Routes.bbSession(program.id, dayIndex),
    );
  }
  if (plan == MissionPlan.run) {
    return ResolvedMission(
      icon: Icons.directions_run_rounded,
      title: l10n.activityRun,
      subtitle: l10n.missionRunHint,
      route: Routes.run,
    );
  }
  final id = plan == null ? null : MissionPlan.routineId(plan);
  final routine = id == null ? null : ref.watch(routineByIdProvider(id));
  return ofRoutine(routine ?? auto);
}

/// Hafta kunining to'liq nomi (Dushanba, Понедельник, Monday).
String weekdayName(BuildContext context, int weekday) {
  // 2024-01-01 — dushanba.
  final date = DateTime(2024, 1, weekday);
  final name = DateFormat.EEEE(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
  return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
}

/// [weekday] uchun vazifani tanlash oynasi.
Future<void> showPlanPicker(
  BuildContext context,
  WidgetRef ref,
  int weekday,
  Routine auto,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PlanPicker(weekday: weekday, auto: auto),
  );
}

class _PlanPicker extends ConsumerWidget {
  const _PlanPicker({required this.weekday, required this.auto});

  final int weekday;
  final Routine auto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schedule = ref.watch(scheduleProvider);
    final current = schedule.plans[weekday];
    final routines = ref.watch(routinesProvider);

    void pick(String? plan) {
      HapticFeedback.selectionClick();
      ref.read(scheduleProvider.notifier).set(schedule.withPlan(weekday, plan));
      Navigator.pop(context);
    }

    Widget option({
      required String? plan,
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      final selected = current == plan;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Material(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => pick(plan),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.title),
                        Text(
                          subtitle,
                          style: AppTextStyles.captionSecondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final bb = resolveMission(context, ref, MissionPlan.bodybuilding, auto);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.missionForDay(weekdayName(context, weekday)),
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(l10n.missionPickHint, style: AppTextStyles.captionSecondary),
          const SizedBox(height: AppSpacing.md),
          option(
            plan: null,
            icon: Icons.auto_awesome_rounded,
            title: l10n.missionAuto,
            subtitle: l10n.missionAutoHint,
          ),
          option(
            plan: MissionPlan.bodybuilding,
            icon: Icons.fitness_center_rounded,
            title: l10n.bodybuilding,
            subtitle: '${l10n.missionBbHint} ${bb.title}',
          ),
          option(
            plan: MissionPlan.run,
            icon: Icons.directions_run_rounded,
            title: l10n.activityRun,
            subtitle: l10n.missionRunHint,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.workout, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          for (final r in routines)
            option(
              plan: MissionPlan.routine(r.id),
              icon: Icons.bolt_rounded,
              title: r.titleOf(context),
              subtitle: '${l10n.minutes(r.minutes)} · ${l10n.kcal(r.kcal)}',
            ),
        ],
      ),
    );
  }
}
