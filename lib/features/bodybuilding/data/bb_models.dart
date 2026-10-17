import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_l10n.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/storage/stored_list.dart';
import 'bb_logic.dart';

// ---------------------------------------------------------------------------
// Mashqlar katalogi
// ---------------------------------------------------------------------------

enum Muscle {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  glutes,
  calves,
  abs,
}

const muscleNames = <Muscle, Tr>{
  Muscle.chest: Tr('Chest', "Ko'krak", 'Грудь'),
  Muscle.back: Tr('Back', 'Orqa', 'Спина'),
  Muscle.shoulders: Tr('Shoulders', 'Yelka', 'Плечи'),
  Muscle.biceps: Tr('Biceps', 'Biseps', 'Бицепс'),
  Muscle.triceps: Tr('Triceps', 'Triseps', 'Трицепс'),
  Muscle.quads: Tr('Quads', "Son oldi", 'Квадрицепс'),
  Muscle.hamstrings: Tr('Hamstrings', 'Son orqasi', 'Бицепс бедра'),
  Muscle.glutes: Tr('Glutes', 'Dumba', 'Ягодицы'),
  Muscle.calves: Tr('Calves', 'Boldir', 'Икры'),
  Muscle.abs: Tr('Abs', 'Qorin', 'Пресс'),
};

extension MuscleL10n on Muscle {
  String label(BuildContext context) => muscleNames[this]!.of(context);
}

class BbExercise {
  const BbExercise(
    this.key,
    this.name,
    this.muscle, {
    this.compound = false,
    this.lowerBody = false,
  });

  /// Inglizcha kalit (tarix shu bilan saqlanadi).
  final String key;
  final Tr name;
  final Muscle muscle;

  /// Asosiy ko'p bo'g'imli mashq — uzunroq dam olish.
  final bool compound;

  /// Progressiv yuklamada +5 kg.
  final bool lowerBody;

  /// Setlar orasidagi dam (soniya).
  int get restSec => compound ? 150 : 75;
}

const _ex = <BbExercise>[
  BbExercise(
    'Bench Press',
    Tr('Bench Press', 'Skameykada shtanga jimi', 'Жим штанги лёжа'),
    Muscle.chest,
    compound: true,
  ),
  BbExercise(
    'Incline Dumbbell Press',
    Tr(
      'Incline Dumbbell Press',
      'Qiya skameykada gantel jimi',
      'Жим гантелей на наклонной',
    ),
    Muscle.chest,
    compound: true,
  ),
  BbExercise(
    'Cable Fly',
    Tr('Cable Fly', 'Krossoverda qo\'l yig\'ish', 'Сведение в кроссовере'),
    Muscle.chest,
  ),
  BbExercise(
    'Chest Dips',
    Tr('Chest Dips', 'Brusda ko\'krak uchun', 'Отжимания на брусьях'),
    Muscle.chest,
    compound: true,
  ),
  BbExercise(
    'Deadlift',
    Tr('Deadlift', 'Stanovaya tortish', 'Становая тяга'),
    Muscle.back,
    compound: true,
    lowerBody: true,
  ),
  BbExercise(
    'Pull Ups',
    Tr('Pull Ups', 'Turnikda tortilish', 'Подтягивания'),
    Muscle.back,
    compound: true,
  ),
  BbExercise(
    'Barbell Row',
    Tr('Barbell Row', 'Shtangani belga tortish', 'Тяга штанги в наклоне'),
    Muscle.back,
    compound: true,
  ),
  BbExercise(
    'Lat Pulldown',
    Tr('Lat Pulldown', 'Yuqori blok tortish', 'Тяга верхнего блока'),
    Muscle.back,
  ),
  BbExercise(
    'Seated Cable Row',
    Tr('Seated Cable Row', "O'tirib blok tortish", 'Тяга блока сидя'),
    Muscle.back,
  ),
  BbExercise(
    'Face Pull',
    Tr('Face Pull', 'Yuzga tortish', 'Тяга к лицу'),
    Muscle.shoulders,
  ),
  BbExercise(
    'Overhead Press',
    Tr('Overhead Press', 'Turib shtanga jimi', 'Армейский жим'),
    Muscle.shoulders,
    compound: true,
  ),
  BbExercise(
    'Lateral Raise',
    Tr(
      'Lateral Raise',
      'Yon tomonga gantel ko\'tarish',
      'Махи гантелями в стороны',
    ),
    Muscle.shoulders,
  ),
  BbExercise(
    'Rear Delt Fly',
    Tr('Rear Delt Fly', 'Orqa delta uchun', 'Разведения на заднюю дельту'),
    Muscle.shoulders,
  ),
  BbExercise(
    'Barbell Curl',
    Tr('Barbell Curl', 'Shtanga bilan biseps', 'Подъём штанги на бицепс'),
    Muscle.biceps,
  ),
  BbExercise(
    'Hammer Curl',
    Tr('Hammer Curl', 'Bolg\'a (hammer)', 'Молотки'),
    Muscle.biceps,
  ),
  BbExercise(
    'Tricep Pushdown',
    Tr('Tricep Pushdown', 'Blokda triseps', 'Разгибания на блоке'),
    Muscle.triceps,
  ),
  BbExercise(
    'Skull Crusher',
    Tr('Skull Crusher', 'Fransuzcha jim', 'Французский жим'),
    Muscle.triceps,
  ),
  BbExercise(
    'Back Squat',
    Tr('Back Squat', 'Shtanga bilan o\'tirib-turish', 'Приседания со штангой'),
    Muscle.quads,
    compound: true,
    lowerBody: true,
  ),
  BbExercise(
    'Leg Press',
    Tr('Leg Press', 'Oyoq pressi', 'Жим ногами'),
    Muscle.quads,
    compound: true,
    lowerBody: true,
  ),
  BbExercise(
    'Leg Extension',
    Tr('Leg Extension', 'Oyoq yozish', 'Разгибание ног'),
    Muscle.quads,
    lowerBody: true,
  ),
  BbExercise(
    'Romanian Deadlift',
    Tr('Romanian Deadlift', 'Rumincha stanovaya', 'Румынская тяга'),
    Muscle.hamstrings,
    compound: true,
    lowerBody: true,
  ),
  BbExercise(
    'Leg Curl',
    Tr('Leg Curl', 'Oyoq bukish', 'Сгибание ног'),
    Muscle.hamstrings,
    lowerBody: true,
  ),
  BbExercise(
    'Hip Thrust',
    Tr('Hip Thrust', 'Dumba ko\'prigi (shtanga)', 'Ягодичный мост со штангой'),
    Muscle.glutes,
    compound: true,
    lowerBody: true,
  ),
  BbExercise(
    'Standing Calf Raise',
    Tr('Standing Calf Raise', 'Turib boldir', 'Подъём на носки стоя'),
    Muscle.calves,
    lowerBody: true,
  ),
  BbExercise(
    'Hanging Leg Raise',
    Tr('Hanging Leg Raise', 'Osilib oyoq ko\'tarish', 'Подъём ног в висе'),
    Muscle.abs,
  ),
  BbExercise(
    'Cable Crunch',
    Tr('Cable Crunch', 'Blokda press', 'Скручивания на блоке'),
    Muscle.abs,
  ),
];

final bbExercises = {for (final e in _ex) e.key: e};

// ---------------------------------------------------------------------------
// Dasturlar
// ---------------------------------------------------------------------------

class Planned {
  const Planned(this.key, this.sets, this.repsMin, this.repsMax);

  final String key;
  final int sets;
  final int repsMin;
  final int repsMax;

  BbExercise get exercise => bbExercises[key]!;
}

class BbDay {
  const BbDay(this.name, this.items);

  final Tr name;
  final List<Planned> items;
}

class BbProgram {
  const BbProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.days,
  });

  final String id;
  final Tr name;
  final Tr description;

  /// 0 — boshlovchi, 1 — o'rta, 2 — yuqori.
  final int level;

  /// Haftalik aylanish (masalan PPL: Push, Pull, Legs, Push, Pull, Legs).
  final List<BbDay> days;
}

const _push = BbDay(Tr('Push', 'Itarish (Push)', 'Жимовой (Push)'), [
  Planned('Bench Press', 4, 6, 8),
  Planned('Overhead Press', 3, 8, 10),
  Planned('Incline Dumbbell Press', 3, 8, 12),
  Planned('Lateral Raise', 4, 12, 15),
  Planned('Tricep Pushdown', 3, 10, 12),
  Planned('Cable Fly', 3, 12, 15),
]);
const _pull = BbDay(Tr('Pull', 'Tortish (Pull)', 'Тяговый (Pull)'), [
  Planned('Deadlift', 3, 4, 6),
  Planned('Pull Ups', 4, 6, 10),
  Planned('Barbell Row', 3, 8, 10),
  Planned('Face Pull', 3, 12, 15),
  Planned('Barbell Curl', 3, 8, 12),
  Planned('Hammer Curl', 3, 10, 12),
]);
const _legs = BbDay(Tr('Legs', 'Oyoqlar', 'Ноги'), [
  Planned('Back Squat', 4, 6, 8),
  Planned('Romanian Deadlift', 3, 8, 10),
  Planned('Leg Press', 3, 10, 12),
  Planned('Leg Curl', 3, 10, 12),
  Planned('Standing Calf Raise', 4, 12, 15),
  Planned('Hanging Leg Raise', 3, 10, 15),
]);

const bbPrograms = <BbProgram>[
  BbProgram(
    id: 'fb3',
    name: Tr('Full Body · 3 days', 'Butun tana · 3 kun', 'Фулбади · 3 дня'),
    description: Tr(
      'Two alternating sessions (A/B) three times a week. The best start: heavy basics and fast progress.',
      'Ikki mashg\'ulot (A/B) navbatma-navbat, haftasiga 3 marta. Eng yaxshi boshlanish: og\'ir bazaviy mashqlar va tez progress.',
      'Две чередующиеся тренировки (A/B) три раза в неделю. Лучший старт: тяжёлая база и быстрый прогресс.',
    ),
    level: 0,
    days: [
      BbDay(Tr('Day A', 'A kun', 'День A'), [
        Planned('Back Squat', 3, 5, 8),
        Planned('Bench Press', 3, 5, 8),
        Planned('Barbell Row', 3, 6, 10),
        Planned('Lateral Raise', 2, 12, 15),
        Planned('Barbell Curl', 2, 10, 12),
        Planned('Hanging Leg Raise', 2, 10, 15),
      ]),
      BbDay(Tr('Day B', 'B kun', 'День B'), [
        Planned('Deadlift', 3, 5, 6),
        Planned('Overhead Press', 3, 6, 10),
        Planned('Lat Pulldown', 3, 8, 12),
        Planned('Leg Press', 3, 10, 12),
        Planned('Tricep Pushdown', 2, 10, 12),
        Planned('Cable Crunch', 2, 12, 15),
      ]),
    ],
  ),
  BbProgram(
    id: 'ul4',
    name: Tr(
      'Upper / Lower · 4 days',
      'Yuqori / Pastki · 4 kun',
      'Верх / Низ · 4 дня',
    ),
    description: Tr(
      'Each muscle twice a week with enough recovery. A classic for hypertrophy.',
      "Har bir mushak haftasiga 2 marta, yetarli tiklanish bilan. Massa uchun klassika.",
      'Каждая мышца дважды в неделю с достаточным восстановлением. Классика для массы.',
    ),
    level: 1,
    days: [
      BbDay(Tr('Upper A', 'Yuqori A', 'Верх A'), [
        Planned('Bench Press', 4, 6, 8),
        Planned('Barbell Row', 4, 6, 8),
        Planned('Overhead Press', 3, 8, 10),
        Planned('Lat Pulldown', 3, 10, 12),
        Planned('Barbell Curl', 3, 10, 12),
        Planned('Skull Crusher', 3, 10, 12),
      ]),
      BbDay(Tr('Lower A', 'Pastki A', 'Низ A'), [
        Planned('Back Squat', 4, 6, 8),
        Planned('Romanian Deadlift', 3, 8, 10),
        Planned('Leg Extension', 3, 12, 15),
        Planned('Leg Curl', 3, 10, 12),
        Planned('Standing Calf Raise', 4, 12, 15),
      ]),
      BbDay(Tr('Upper B', 'Yuqori B', 'Верх B'), [
        Planned('Incline Dumbbell Press', 4, 8, 10),
        Planned('Pull Ups', 4, 6, 10),
        Planned('Seated Cable Row', 3, 10, 12),
        Planned('Lateral Raise', 4, 12, 15),
        Planned('Hammer Curl', 3, 10, 12),
        Planned('Tricep Pushdown', 3, 10, 12),
      ]),
      BbDay(Tr('Lower B', 'Pastki B', 'Низ B'), [
        Planned('Deadlift', 3, 4, 6),
        Planned('Leg Press', 4, 10, 12),
        Planned('Hip Thrust', 3, 8, 12),
        Planned('Leg Curl', 3, 10, 12),
        Planned('Hanging Leg Raise', 3, 10, 15),
      ]),
    ],
  ),
  BbProgram(
    id: 'bro5',
    name: Tr('Bro Split · 5 days', 'Bro split · 5 kun', 'Бро-сплит · 5 дней'),
    description: Tr(
      'One big muscle group per day with high volume. For experienced lifters with good recovery.',
      "Har kuni bitta katta mushak guruhi, yuqori hajm bilan. Yaxshi tiklanadigan tajribalilar uchun.",
      'Одна крупная группа мышц в день с большим объёмом. Для опытных с хорошим восстановлением.',
    ),
    level: 1,
    days: [
      BbDay(Tr('Chest', "Ko'krak", 'Грудь'), [
        Planned('Bench Press', 4, 6, 8),
        Planned('Incline Dumbbell Press', 4, 8, 10),
        Planned('Chest Dips', 3, 8, 12),
        Planned('Cable Fly', 3, 12, 15),
      ]),
      BbDay(Tr('Back', 'Orqa', 'Спина'), [
        Planned('Deadlift', 3, 4, 6),
        Planned('Pull Ups', 4, 6, 10),
        Planned('Barbell Row', 4, 8, 10),
        Planned('Seated Cable Row', 3, 10, 12),
      ]),
      BbDay(Tr('Shoulders', 'Yelka', 'Плечи'), [
        Planned('Overhead Press', 4, 6, 8),
        Planned('Lateral Raise', 5, 12, 15),
        Planned('Rear Delt Fly', 4, 12, 15),
        Planned('Face Pull', 3, 12, 15),
      ]),
      _legs,
      BbDay(Tr('Arms', "Qo'llar", 'Руки'), [
        Planned('Barbell Curl', 4, 8, 12),
        Planned('Skull Crusher', 4, 8, 12),
        Planned('Hammer Curl', 3, 10, 12),
        Planned('Tricep Pushdown', 3, 10, 12),
      ]),
    ],
  ),
  BbProgram(
    id: 'ppl6',
    name: Tr(
      'Push / Pull / Legs · 6 days',
      'Push / Pull / Legs · 6 kun',
      'Push / Pull / Legs · 6 дней',
    ),
    description: Tr(
      'The most popular advanced split: each muscle twice a week with high volume.',
      "Eng mashhur ilg'or split: har bir mushak haftasiga 2 marta, yuqori hajm bilan.",
      'Самый популярный продвинутый сплит: каждая мышца дважды в неделю с большим объёмом.',
    ),
    level: 2,
    days: [_push, _pull, _legs, _push, _pull, _legs],
  ),
];

BbProgram programById(String id) =>
    bbPrograms.firstWhere((p) => p.id == id, orElse: () => bbPrograms.first);

// ---------------------------------------------------------------------------
// Tarix
// ---------------------------------------------------------------------------

/// Bitta mashqning bajarilgan setlari.
class LoggedExercise {
  const LoggedExercise(this.key, this.sets);

  final String key;
  final List<SetResult> sets;

  Map<String, Object?> toJson() => {
    'key': key,
    'sets': [
      for (final s in sets) [s.weightKg, s.reps],
    ],
  };

  static LoggedExercise fromJson(Map<String, Object?> j) =>
      LoggedExercise(j['key'] as String, [
        for (final s in j['sets'] as List)
          SetResult(
            weightKg: ((s as List)[0] as num).toDouble(),
            reps: (s[1] as num).toInt(),
          ),
      ]);
}

class BbSession {
  const BbSession({
    required this.date,
    required this.programId,
    required this.dayIndex,
    required this.minutes,
    required this.exercises,
  });

  final DateTime date;
  final String programId;
  final int dayIndex;
  final int minutes;
  final List<LoggedExercise> exercises;

  double get volume => exercises.fold(0, (s, e) => s + volumeOf(e.sets));
  int get setCount => exercises.fold(0, (s, e) => s + e.sets.length);

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'programId': programId,
    'dayIndex': dayIndex,
    'minutes': minutes,
    'exercises': [for (final e in exercises) e.toJson()],
  };

  static BbSession fromJson(Map<String, Object?> j) => BbSession(
    date: DateTime.parse(j['date'] as String),
    programId: j['programId'] as String,
    dayIndex: (j['dayIndex'] as num).toInt(),
    minutes: (j['minutes'] as num).toInt(),
    exercises: [
      for (final e in j['exercises'] as List)
        LoggedExercise.fromJson(e as Map<String, Object?>),
    ],
  );
}

/// Bodybuilding mashg'ulotlari tarixi — yangilari tepada.
final bbHistoryProvider =
    StateNotifierProvider<BbHistoryNotifier, List<BbSession>>(
      (ref) => BbHistoryNotifier(ref),
    );

class BbHistoryNotifier extends StoredList<BbSession> {
  BbHistoryNotifier(Ref ref) : super(ref, 'bb_history');

  @override
  BbSession decode(Map<String, Object?> json) => BbSession.fromJson(json);
  @override
  Map<String, Object?> encode(BbSession item) => item.toJson();

  void add(BbSession s) => save([s, ...state]);
}

/// Tanlangan dastur (telefonda saqlanadi).
final bbProgramIdProvider = StateNotifierProvider<BbProgramNotifier, String>(
  (ref) => BbProgramNotifier(ref),
);

class BbProgramNotifier extends StateNotifier<String> {
  BbProgramNotifier(this._ref)
    : super(_ref.read(sharedPrefsProvider).getString(_key) ?? 'fb3');

  static const _key = 'bb_program';
  final Ref _ref;

  void set(String id) {
    state = id;
    _ref.read(sharedPrefsProvider).setString(_key, id);
  }
}

/// Navbatdagi kun: shu dasturdagi oxirgi mashg'ulotdan keyingisi.
final bbNextDayProvider = Provider<int>((ref) {
  final programId = ref.watch(bbProgramIdProvider);
  final days = programById(programId).days.length;
  final last = ref
      .watch(bbHistoryProvider)
      .where((s) => s.programId == programId)
      .firstOrNull;
  return last == null ? 0 : (last.dayIndex + 1) % days;
});

/// Mashqning oxirgi bajarilgan setlari (progressiv yuklama va "o'tgan safar" uchun).
final lastSetsProvider = Provider.family<List<SetResult>, String>((ref, key) {
  for (final s in ref.watch(bbHistoryProvider)) {
    for (final e in s.exercises) {
      if (e.key == key && e.sets.isNotEmpty) return e.sets;
    }
  }
  return const [];
});

/// Shaxsiy rekord — eng yaxshi taxminiy 1RM.
final personalRecordProvider = Provider.family<double, String>((ref, key) {
  var best = 0.0;
  for (final s in ref.watch(bbHistoryProvider)) {
    for (final e in s.exercises.where((e) => e.key == key)) {
      for (final set in e.sets) {
        final rm = estimate1Rm(set.weightKg, set.reps);
        if (rm > best) best = rm;
      }
    }
  }
  return best;
});

/// Oxirgi 7 kunda mushak guruhi bo'yicha ishchi setlar soni.
final weeklySetsByMuscleProvider = Provider<Map<Muscle, int>>((ref) {
  final since = DateTime.now().subtract(const Duration(days: 7));
  final result = {for (final m in Muscle.values) m: 0};
  for (final s
      in ref.watch(bbHistoryProvider).where((s) => s.date.isAfter(since))) {
    for (final e in s.exercises) {
      final m = bbExercises[e.key]?.muscle;
      if (m != null) result[m] = result[m]! + e.sets.length;
    }
  }
  return result;
});
