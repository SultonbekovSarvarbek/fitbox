import '../../../core/content/content_l10n.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/storage/stored_list.dart';
import '../../nutrition/data/nutrition_goals.dart';
import '../../setup/setup_profile.dart';
import '../../workout/data/met.dart';
import '../../workout/data/workout_models.dart';

/// Bajarilgan bitta mashg'ulot.
class LogEntry {
  const LogEntry({
    required this.date,
    required this.title,
    required this.minutes,
    required this.kcal,
    this.level,
    this.routineId,
    this.activity,
    this.distanceKm,
  });

  final DateTime date;
  final String title;

  /// Mashg'ulot darajasi (`ActivityLevel.name`) — diagramma uchun.
  final String? level;

  /// Til almashganda nom to'g'ri chiqishi uchun: mashg'ulot id'si…
  final String? routineId;

  /// …yoki yugurish turi (`RunActivity.name`) va masofasi (km).
  final String? activity;
  final double? distanceKm;

  /// Haqiqiy davomiylik (player'dagi vaqt, pauzalarsiz).
  final int minutes;

  /// Faol kaloriya: (MET − 1) × vazn × vaqt.
  final int kcal;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'title': title,
    'minutes': minutes,
    'kcal': kcal,
    'level': level,
    'routineId': routineId,
    'activity': activity,
    'distanceKm': distanceKm,
  };

  static LogEntry fromJson(Map<String, Object?> j) => LogEntry(
    date: DateTime.parse(j['date'] as String),
    title: j['title'] as String,
    minutes: (j['minutes'] as num).toInt(),
    kcal: (j['kcal'] as num).toInt(),
    level: j['level'] as String?,
    routineId: j['routineId'] as String?,
    activity: j['activity'] as String?,
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
  );
}

/// Vazn o'lchovi.
class WeightEntry {
  const WeightEntry({required this.date, required this.kg});

  final DateTime date;
  final double kg;

  Map<String, Object?> toJson() => {'date': date.toIso8601String(), 'kg': kg};

  static WeightEntry fromJson(Map<String, Object?> j) => WeightEntry(
    date: DateTime.parse(j['date'] as String),
    kg: (j['kg'] as num).toDouble(),
  );
}

/// 7.2.1 Workout Log — faqat haqiqatan bajarilgan mashg'ulotlar, yangilari tepada.
/// TODO(backend): serverga sinxronlash.
final workoutLogProvider =
    StateNotifierProvider<WorkoutLogNotifier, List<LogEntry>>(
      (ref) => WorkoutLogNotifier(ref),
    );

class WorkoutLogNotifier extends StoredList<LogEntry> {
  WorkoutLogNotifier(Ref ref) : super(ref, 'workout_log');

  @override
  LogEntry decode(Map<String, Object?> json) => LogEntry.fromJson(json);
  @override
  Map<String, Object?> encode(LogEntry item) => item.toJson();

  void add(LogEntry entry) => save([entry, ...state]);
}

/// 7.2.2 Vazn tarixi — eskisidan yangisiga.
final weightLogProvider =
    StateNotifierProvider<WeightLogNotifier, List<WeightEntry>>(
      (ref) => WeightLogNotifier(ref),
    );

class WeightLogNotifier extends StoredList<WeightEntry> {
  WeightLogNotifier(Ref ref) : super(ref, 'weight_log');

  @override
  WeightEntry decode(Map<String, Object?> json) => WeightEntry.fromJson(json);
  @override
  Map<String, Object?> encode(WeightEntry item) => item.toJson();

  /// Bir kunda bitta yozuv: o'sha kunga qayta kiritilsa — almashtiriladi.
  /// Profildagi joriy vazn ham yangilanadi.
  void add(double kg, {DateTime? at}) {
    final date = at ?? DateTime.now();
    final rest = state.where((e) => !_sameDay(e.date, date));
    save(
      [...rest, WeightEntry(date: date, kg: kg)]
        ..sort((a, b) => a.date.compareTo(b.date)),
    );
    ref.read(userProvider.notifier).state = ref.read(userProvider).copy()
      ..weightKg = kg.round();
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Oxirgi 7 kun bo'yicha kaloriya (0 = 6 kun oldin, 6 = bugun).
final weeklyKcalProvider = Provider<List<int>>((ref) {
  final log = ref.watch(workoutLogProvider);
  final today = _day(DateTime.now());
  final result = List.filled(7, 0);
  for (final e in log) {
    final diff = today.difference(_day(e.date)).inDays;
    if (diff >= 0 && diff < 7) result[6 - diff] += e.kcal;
  }
  return result;
});

/// Statistika jamlanmasi.
class ProgressStats {
  const ProgressStats({
    required this.weekWorkouts,
    required this.weekMinutes,
    required this.weekKcal,
    required this.totalWorkouts,
    required this.totalKcal,
    required this.streakDays,
  });

  final int weekWorkouts;
  final int weekMinutes;
  final int weekKcal;
  final int totalWorkouts;
  final int totalKcal;

  /// Ketma-ket mashg'ulot qilingan kunlar (bugun yoki kechadan boshlab).
  final int streakDays;
}

final progressStatsProvider = Provider<ProgressStats>((ref) {
  final log = ref.watch(workoutLogProvider);
  final today = _day(DateTime.now());
  final week = log.where((e) => today.difference(_day(e.date)).inDays < 7);

  final days = {for (final e in log) _day(e.date)};
  var cursor = days.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return ProgressStats(
    weekWorkouts: week.length,
    weekMinutes: week.fold(0, (s, e) => s + e.minutes),
    weekKcal: week.fold(0, (s, e) => s + e.kcal),
    totalWorkouts: log.length,
    totalKcal: log.fold(0, (s, e) => s + e.kcal),
    streakDays: streak,
  );
});

/// Haftalik kaloriya maqsadi — shaxsiy: vazn, bo'y, yosh, jins, faollik va maqsad bo'yicha.
final weeklyKcalGoalProvider = Provider<int>(
  (ref) => weeklyBurnGoalFor(ref.watch(userProvider)),
);

/// Kunlik kaloriya — oxirgi [days] kun (0 = eng eski, oxirgisi = bugun). Faollik kalendari uchun.
final dailyKcalProvider = Provider.family<List<int>, int>((ref, days) {
  final log = ref.watch(workoutLogProvider);
  final today = _day(DateTime.now());
  final result = List.filled(days, 0);
  for (final e in log) {
    final diff = today.difference(_day(e.date)).inDays;
    if (diff >= 0 && diff < days) result[days - 1 - diff] += e.kcal;
  }
  return result;
});

/// Haftalik daqiqalar — oxirgi [weeks] hafta (oxirgisi = joriy 7 kun).
final weeklyMinutesProvider = Provider.family<List<int>, int>((ref, weeks) {
  final log = ref.watch(workoutLogProvider);
  final today = _day(DateTime.now());
  final result = List.filled(weeks, 0);
  for (final e in log) {
    final w = today.difference(_day(e.date)).inDays ~/ 7;
    if (w >= 0 && w < weeks) result[weeks - 1 - w] += e.minutes;
  }
  return result;
});

/// Daraja bo'yicha mashg'ulotlar soni.
final levelSplitProvider = Provider<Map<ActivityLevel, int>>((ref) {
  final result = {for (final l in ActivityLevel.values) l: 0};
  for (final e in ref.watch(workoutLogProvider)) {
    final level = ActivityLevel.values
        .where((l) => l.name == e.level)
        .firstOrNull;
    if (level != null) result[level] = result[level]! + 1;
  }
  return result;
});

// ---------------------------------------------------------------------------
// Test (demo) ma'lumotlar
// ---------------------------------------------------------------------------

const _demoSeededKey = 'demo_seeded';

/// Birinchi ishga tushishda statistika bo'sh bo'lmasligi uchun realistik tarix:
/// oxirgi 8 hafta, haftasiga 4–5 mashg'ulot, 10 ta vazn o'lchovi.
/// Kaloriya haqiqiy formula (MET × vazn × vaqt) bilan hisoblanadi.
/// Sozlamalar → "Test ma'lumotlarni tozalash" bilan o'chiriladi.
final demoSeedProvider = Provider<void>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  if (prefs.getBool(_demoSeededKey) ?? false) return;
  if (ref.read(workoutLogProvider).isNotEmpty) return;
  prefs.setBool(_demoSeededKey, true);

  final rnd = math.Random(42);
  final weight = ref.read(userProvider).weightKg.toDouble();
  final routines = ref
      .read(routineStoreProvider)
      .where((r) => !r.isCustom)
      .toList();
  final today = _day(DateTime.now());

  final log = <LogEntry>[];
  for (var d = 55; d >= 0; d--) {
    // Yakshanba — dam olish, qolgan kunlar ~65% ehtimol bilan mashg'ulot.
    final date = today.subtract(Duration(days: d));
    if (date.weekday == DateTime.sunday || rnd.nextDouble() > 0.65) continue;
    final r = routines[rnd.nextInt(routines.length)];
    final minutes = (r.minutes + rnd.nextInt(7) - 3).clamp(5, 90);
    log.add(
      LogEntry(
        date: date.add(
          Duration(hours: 7 + rnd.nextInt(12), minutes: rnd.nextInt(60)),
        ),
        title: r.title,
        minutes: minutes,
        kcal: kcalFor(
          met: r.met,
          weightKg: weight,
          minutes: minutes.toDouble(),
        ),
        level: r.level.name,
        routineId: r.id,
      ),
    );
  }
  ref.read(workoutLogProvider.notifier).save(log.reversed.toList());

  // Vazn: 9 hafta oldin +3 kg, sekin pasayib joriy vaznga keladi.
  final weights = ref.read(weightLogProvider.notifier);
  final entries = <WeightEntry>[];
  for (var w = 9; w >= 0; w--) {
    final kg = weight + 3 * w / 9 + (rnd.nextDouble() - 0.5) * 0.6;
    entries.add(
      WeightEntry(
        date: today.subtract(Duration(days: w * 7)),
        kg: double.parse((w == 0 ? weight : kg).toStringAsFixed(1)),
      ),
    );
  }
  weights.save(entries);
});

/// Barcha statistika (jurnal + vazn) o'chiriladi; demo qayta yaratilmaydi.
void clearProgressData(WidgetRef ref) {
  ref.read(workoutLogProvider.notifier).clear();
  ref.read(weightLogProvider.notifier).clear();
}

/// Bugun mashg'ulot va yugurishlarda sarflangan kaloriya (jurnaldan avtomatik).
final todayBurnedKcalProvider = Provider<int>((ref) {
  final today = _day(DateTime.now());
  return ref
      .watch(workoutLogProvider)
      .where((e) => _day(e.date) == today)
      .fold(0, (s, e) => s + e.kcal);
});

extension LogEntryL10n on LogEntry {
  /// Tanlangan tildagi nom: mashg'ulot — katalogdan, yugurish — "Yugurish · 2.15 km".
  String titleOf(BuildContext context) {
    final l10n = context.l10n;
    if (activity != null && distanceKm != null) {
      final label = switch (activity) {
        'walk' => l10n.activityWalk,
        'bike' => l10n.activityBike,
        _ => l10n.activityRun,
      };
      return l10n.runLogTitle(label, distanceKm!.toStringAsFixed(2));
    }
    final byId = routineTitles[routineId];
    if (byId != null) return byId.of(context);
    // Eski yozuvlarda id yo'q — inglizcha nom bo'yicha topamiz.
    for (final t in routineTitles.values) {
      if (t.en == title) return t.of(context);
    }
    return title;
  }
}
