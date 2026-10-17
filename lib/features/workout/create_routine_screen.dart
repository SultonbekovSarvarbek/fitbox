import '../../core/content/content_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';
import 'data/workout_models.dart';
import 'widgets/routine_card.dart';

/// 7.1.2 Make your own routine.
class CreateRoutineScreen extends ConsumerStatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  ConsumerState<CreateRoutineScreen> createState() =>
      _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _name = TextEditingController();
  var _level = ActivityLevel.beginner;
  final _selected = <String>{};

  // TODO(backend): mashqlar kutubxonasi serverdan.
  static const _library = [
    'Push Ups',
    'Pull Ups',
    'Bodyweight Squat',
    'Lunges',
    'Plank',
    'Burpees',
    'Jumping Jacks',
    'Mountain Climbers',
    'Glute Bridge',
    'Crunches',
    'Dumbbell Rows',
    'Shoulder Press',
    'Tricep Dips',
    'Calf Raises',
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final name = _name.text.trim();
    if (name.isEmpty || _selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineIncomplete)));
      return;
    }
    final exercises = [for (final n in _selected) Exercise(name: n)];
    ref
        .read(routineStoreProvider.notifier)
        .add(
          Routine(
            id: 'c${DateTime.now().millisecondsSinceEpoch}',
            title: name,
            level: _level,
            // Taxminiy vaqt: har bir mashq ~4 daqiqa. Kaloriya vazn bo'yicha avtomatik.
            minutes: exercises.length * 4,
            exercises: exercises,
            isCustom: true,
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.routineSaved)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.makeYourOwnRoutine)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: AppTextField(
                    label: l10n.routineName,
                    controller: _name,
                    prefixIcon: Icons.edit_note_rounded,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PillTabs(
                  labels: [
                    for (final l in ActivityLevel.values) l.label(context),
                  ],
                  selected: _level.index,
                  onChanged: (i) =>
                      setState(() => _level = ActivityLevel.values[i]),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(l10n.chooseExercises, style: AppTextStyles.h3),
                ),
                for (final name in _library)
                  CheckboxListTile(
                    value: _selected.contains(name),
                    onChanged: (v) => setState(
                      () => v! ? _selected.add(name) : _selected.remove(name),
                    ),
                    title: Text(
                      trKey(context, exerciseNames, name),
                      style: AppTextStyles.body,
                    ),
                    activeColor: AppColors.primary,
                    checkColor: AppColors.textOnPrimary,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryButton(
              label: '${l10n.saveRoutine} (${_selected.length})',
              expanded: true,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}
