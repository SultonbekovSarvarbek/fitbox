import 'dart:math' as math;

/// Intizom: jadval, seriya, XP/daraja — sof mantiq (unit-test qilinadi).

/// Mashg'ulot jadvali: hafta kunlari (1 = dushanba … 7 = yakshanba) va eslatma vaqti.
class TrainingSchedule {
  const TrainingSchedule({
    this.weekdays = const {1, 3, 5},
    this.hour = 19,
    this.minute = 0,
    this.enabled = false,
    this.plans = const {},
  });

  final Set<int> weekdays;
  final int hour;
  final int minute;

  /// Eslatmalar yoqilganmi.
  final bool enabled;

  /// Kun bo'yicha o'zi tanlagan vazifa: hafta kuni → [MissionPlan] kaliti.
  /// Yo'q bo'lsa — avtomatik tavsiya.
  final Map<int, String> plans;

  bool isTrainingDay(DateTime d) =>
      weekdays.isEmpty || weekdays.contains(d.weekday);

  TrainingSchedule copyWith({
    Set<int>? weekdays,
    int? hour,
    int? minute,
    bool? enabled,
    Map<int, String>? plans,
  }) => TrainingSchedule(
    weekdays: weekdays ?? this.weekdays,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
    plans: plans ?? this.plans,
  );

  /// [weekday] uchun vazifa; `null` — avtomatik. Vazifa tanlangan kun mashg'ulot kuniga aylanadi.
  TrainingSchedule withPlan(int weekday, String? plan) {
    final next = {...plans};
    if (plan == null) {
      next.remove(weekday);
      return copyWith(plans: next);
    }
    next[weekday] = plan;
    return copyWith(plans: next, weekdays: {...weekdays, weekday});
  }

  Map<String, Object?> toJson() => {
    'weekdays': weekdays.toList()..sort(),
    'hour': hour,
    'minute': minute,
    'enabled': enabled,
    'plans': {for (final e in plans.entries) '${e.key}': e.value},
  };

  static TrainingSchedule fromJson(Map<String, Object?> j) => TrainingSchedule(
    weekdays: {for (final d in j['weekdays'] as List) (d as num).toInt()},
    hour: (j['hour'] as num).toInt(),
    minute: (j['minute'] as num).toInt(),
    enabled: j['enabled'] as bool? ?? false,
    plans: {
      for (final e in ((j['plans'] as Map?) ?? const {}).entries)
        int.parse(e.key as String): e.value as String,
    },
  );
}

/// Vazifa kalitlari: `bb` — bodybuilding (navbatdagi kun), `run` — yugurish,
/// `routine:<id>` — tayyor mashg'ulot.
abstract final class MissionPlan {
  static const bodybuilding = 'bb';
  static const run = 'run';
  static String routine(String id) => 'routine:$id';

  static String? routineId(String plan) =>
      plan.startsWith('routine:') ? plan.substring(8) : null;
}

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Jadvalga ko'ra seriya: bugundan orqaga qarab, ketma-ket BAJARILGAN mashg'ulot kunlari.
/// Dam olish kunlari seriyani uzmaydi (lekin qo'shmaydi ham, faqat shu kuni mashg'ulot
/// qilingan bo'lsa — bonus sifatida qo'shiladi). Bugun hali kech emas — bugun bajarilmagan
/// bo'lsa ham seriya uzilmaydi.
int scheduleStreak({
  required Set<DateTime> workoutDays,
  required TrainingSchedule schedule,
  required DateTime today,
}) {
  final done = {for (final d in workoutDays) dayOf(d)};
  if (done.isEmpty) return 0;
  final first = done.reduce((a, b) => a.isBefore(b) ? a : b);
  var cursor = dayOf(today);
  var streak = 0;
  // Bugun: bajarilgan bo'lsa — hisoblanadi, bo'lmasa — o'tkazib yuboriladi (kun tugamagan).
  if (done.contains(cursor)) streak++;
  cursor = cursor.subtract(const Duration(days: 1));
  for (var i = 0; i < 400; i++) {
    final isDone = done.contains(cursor);
    if (isDone) {
      streak++;
    } else if (schedule.isTrainingDay(cursor)) {
      break; // rejalashtirilgan kun o'tkazib yuborilgan — seriya shu yerda uziladi
    }
    cursor = cursor.subtract(const Duration(days: 1));
    // Jadval bo'yicha hech qachon mashg'ulot bo'lmagan uzoq o'tmishga ketmaslik uchun.
    if (cursor.isBefore(first)) break;
  }
  return streak;
}

/// Eng uzun seriya (yutuqlar uchun) — oddiy ketma-ket kunlar.
int longestDailyStreak(Set<DateTime> workoutDays) {
  final days = workoutDays.map(dayOf).toSet().toList()..sort();
  var best = 0, cur = 0;
  DateTime? prev;
  for (final d in days) {
    cur = prev != null && d.difference(prev).inDays == 1 ? cur + 1 : 1;
    best = math.max(best, cur);
    prev = d;
  }
  return best;
}

/// XP: har mashg'ulot uchun 50 + kaloriya / 5.
int xpFor({required int workouts, required int totalKcal}) =>
    workouts * 50 + totalKcal ~/ 5;

/// Daraja: 1 + √(xp / 150). Keyingi darajagacha progress ham qaytariladi.
({int level, double progress, int nextAt}) levelFor(int xp) {
  final level = 1 + math.sqrt(xp / 150).floor();
  int startOf(int l) => 150 * (l - 1) * (l - 1);
  final start = startOf(level);
  final next = startOf(level + 1);
  return (level: level, progress: (xp - start) / (next - start), nextAt: next);
}
