import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_l10n.dart';
import 'package:flutter/widgets.dart';
import '../../setup/setup_profile.dart';
import 'met.dart';

class Exercise {
  const Exercise({
    required this.name,
    this.sets = 3,
    this.reps = 12,
    this.seconds,
  });

  final String name;
  final int sets;
  final int reps;

  /// Vaqtga asoslangan mashqlar uchun (plank, stretching) — `reps` o'rniga.
  final int? seconds;

  /// Mashq og'irligi (kaloriya hisobi uchun) — `met.dart`.
  double get met => metFor(name);
}

class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.level,
    required this.minutes,
    required this.exercises,
    this.isCustom = false,
    this.kcal = 0,
  });

  final String id;
  final String title;
  final ActivityLevel level;
  final int minutes;
  final List<Exercise> exercises;
  final bool isCustom;

  /// Foydalanuvchi vazni bo'yicha hisoblangan kaloriya — `routinesProvider` to'ldiradi.
  final int kcal;

  /// Mashqlarning o'rtacha MET qiymati.
  double get met => exercises.isEmpty
      ? 4.0
      : exercises.fold(0.0, (s, e) => s + e.met) / exercises.length;

  Routine withKcal(int value) => Routine(
    id: id,
    title: title,
    level: level,
    minutes: minutes,
    exercises: exercises,
    isCustom: isCustom,
    kcal: value,
  );
}

/// 7.1.1 Preset Routines + 7.1.2 foydalanuvchi o'zi tuzganlari (kaloriyasiz, xom ro'yxat).
/// Qo'shish: `ref.read(routineStoreProvider.notifier).add(...)`.
/// TODO(backend): serverdan / AI plan_generator'dan olinadi.
final routineStoreProvider =
    StateNotifierProvider<RoutinesNotifier, List<Routine>>(
      (ref) => RoutinesNotifier(),
    );

/// Ekranlar shuni ishlatadi: har bir reja kaloriyasi foydalanuvchi vazni bo'yicha.
final routinesProvider = Provider<List<Routine>>((ref) {
  final weight = ref.watch(userProvider.select((u) => u.weightKg)).toDouble();
  return [
    for (final r in ref.watch(routineStoreProvider))
      r.withKcal(
        kcalFor(met: r.met, weightKg: weight, minutes: r.minutes.toDouble()),
      ),
  ];
});

class RoutinesNotifier extends StateNotifier<List<Routine>> {
  RoutinesNotifier() : super(_presets);

  void add(Routine routine) => state = [...state, routine];

  static const _presets = [
    Routine(
      id: 'b1',
      title: 'Full Body Starter',
      level: ActivityLevel.beginner,
      minutes: 15,
      exercises: [
        Exercise(name: 'Jumping Jacks', sets: 2, seconds: 30),
        Exercise(name: 'Bodyweight Squat', sets: 3, reps: 12),
        Exercise(name: 'Knee Push Ups', sets: 3, reps: 8),
        Exercise(name: 'Plank', sets: 2, seconds: 20),
      ],
    ),
    Routine(
      id: 'b2',
      title: 'Morning Stretching',
      level: ActivityLevel.beginner,
      minutes: 10,
      exercises: [
        Exercise(name: 'Neck Rolls', sets: 1, seconds: 30),
        Exercise(name: 'Cat-Cow', sets: 2, reps: 10),
        Exercise(name: 'Hamstring Stretch', sets: 2, seconds: 30),
      ],
    ),
    Routine(
      id: 'i1',
      title: 'Upper Body Power',
      level: ActivityLevel.intermediate,
      minutes: 25,
      exercises: [
        Exercise(name: 'Push Ups', sets: 4, reps: 15),
        Exercise(name: 'Dumbbell Rows', sets: 4, reps: 12),
        Exercise(name: 'Shoulder Press', sets: 3, reps: 12),
        Exercise(name: 'Tricep Dips', sets: 3, reps: 12),
      ],
    ),
    Routine(
      id: 'i2',
      title: 'Leg Day',
      level: ActivityLevel.intermediate,
      minutes: 30,
      exercises: [
        Exercise(name: 'Goblet Squat', sets: 4, reps: 12),
        Exercise(name: 'Lunges', sets: 3, reps: 12),
        Exercise(name: 'Glute Bridge', sets: 3, reps: 15),
        Exercise(name: 'Calf Raises', sets: 3, reps: 20),
      ],
    ),
    Routine(
      id: 'a1',
      title: 'HIIT Burner',
      level: ActivityLevel.advanced,
      minutes: 35,
      exercises: [
        Exercise(name: 'Burpees', sets: 5, reps: 15),
        Exercise(name: 'Jump Squats', sets: 5, reps: 20),
        Exercise(name: 'Mountain Climbers', sets: 5, seconds: 45),
        Exercise(name: 'Plank With Hip Twist', sets: 4, seconds: 45),
      ],
    ),
    Routine(
      id: 'a2',
      title: 'Strength Complex',
      level: ActivityLevel.advanced,
      minutes: 45,
      exercises: [
        Exercise(name: 'Deadlift', sets: 5, reps: 5),
        Exercise(name: 'Bench Press', sets: 5, reps: 5),
        Exercise(name: 'Pull Ups', sets: 4, reps: 10),
        Exercise(name: 'Overhead Press', sets: 4, reps: 8),
      ],
    ),
  ];
}

final routineByIdProvider = Provider.family<Routine?, String>((ref, id) {
  for (final r in ref.watch(routinesProvider)) {
    if (r.id == id) return r;
  }
  return null;
});

extension ExerciseL10n on Exercise {
  /// Tanlangan tildagi nom (MET, pose, rasm uchun esa `name` — inglizcha kalit).
  String nameOf(BuildContext context) => trKey(context, exerciseNames, name);
}

extension RoutineL10n on Routine {
  String titleOf(BuildContext context) =>
      routineTitles[id]?.of(context) ?? title;

  /// Qisqa tavsif (o'zi tuzgan rejalarda — yo'q).
  String? descriptionOf(BuildContext context) =>
      routineDescriptions[id]?.of(context);
}
