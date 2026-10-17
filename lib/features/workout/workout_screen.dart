import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../setup/setup_profile.dart';
import 'data/workout_models.dart';
import 'widgets/routine_card.dart';

/// 7.1 Workout — design/2.png "Browse":
/// tablar (Beginner / Intermediate / Advanced / Mening rejalarim), filtr qatori, 2 ustunli grid.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _tab = 0; // 0..2 = daraja, 3 = o'zim tuzganlar
  String _query = '';
  bool _sortByTime = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = ref.watch(routinesProvider);
    var routines = _tab == 3
        ? all.where((r) => r.isCustom).toList()
        : all
              .where(
                (r) => !r.isCustom && r.level == ActivityLevel.values[_tab],
              )
              .toList();
    if (_query.isNotEmpty) {
      routines = routines
          .where(
            (r) =>
                r.titleOf(context).toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }
    if (_sortByTime) routines.sort((a, b) => a.minutes.compareTo(b.minutes));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.browse)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: const CircleBorder(),
        tooltip: l10n.makeYourOwnRoutine,
        onPressed: () async {
          await context.push(Routes.createRoutine);
          if (mounted) setState(() => _tab = 3);
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          PillTabs(
            labels: [
              for (final level in ActivityLevel.values) level.label(context),
              l10n.myRoutines,
            ],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                IconChip(
                  icon: Icons.swap_vert_rounded,
                  label: l10n.sorting,
                  color: _sortByTime
                      ? AppColors.surfaceLight
                      : AppColors.surface,
                  onTap: () => setState(() => _sortByTime = !_sortByTime),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.body,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        border: _pill,
                        enabledBorder: _pill,
                        focusedBorder: _pill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: routines.isEmpty
                ? Center(
                    child: Text(
                      l10n.noRoutinesYet,
                      style: AppTextStyles.bodySecondary,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      96,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: routines.length,
                    itemBuilder: (_, i) => RoutineCard(
                      routine: routines[i],
                      onTap: () => context.push(Routes.routine(routines[i].id)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static final _pill = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    borderSide: const BorderSide(color: AppColors.border),
  );
}
