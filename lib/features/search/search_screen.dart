import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/media_placeholder.dart';
import '../../core/widgets/pill_tabs.dart';
import '../nutrition/data/nutrition_models.dart';
import '../workout/data/workout_models.dart';

/// 6.3 Search: 6.3.1 All · 6.3.2 Workout · 6.3.3 Nutrition.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  int _tab = 0;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _q.toLowerCase();
    final routines = _tab == 2
        ? <Routine>[]
        : ref
              .watch(routinesProvider)
              .where((r) => r.titleOf(context).toLowerCase().contains(q))
              .toList();
    final meals = _tab == 1
        ? <Meal>[]
        : demoMeals
              .where((m) => m.titleOf(context).toLowerCase().contains(q))
              .toList();

    final results = <Widget>[
      for (final r in routines)
        _ResultTile(
          icon: Icons.fitness_center_rounded,
          title: r.titleOf(context),
          subtitle: '${l10n.workout} · ${l10n.minutes(r.minutes)}',
          onTap: () => context.go(Routes.routine(r.id)),
        ),
      for (final m in meals)
        _ResultTile(
          icon: Icons.ramen_dining_rounded,
          title: m.titleOf(context),
          subtitle: '${l10n.nutrition} · ${l10n.kcal(m.kcal)}',
          onTap: () => context.go(Routes.meal(m.id)),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _q = v),
            style: AppTextStyles.body,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          PillTabs(
            labels: [l10n.all, l10n.workout, l10n.nutrition],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      l10n.noResults,
                      style: AppTextStyles.bodySecondary,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => results[i],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          MediaPlaceholder(
            icon: icon,
            width: 56,
            height: 56,
            radius: AppRadius.md,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                Text(subtitle, style: AppTextStyles.captionSecondary),
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
