import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../progress/data/progress_models.dart';
import '../../workout/data/workout_models.dart';
import 'discipline.dart';
import 'reminder_service.dart';

const _scheduleKey = 'training_schedule';

/// Mashg'ulot jadvali (Sozlamalar → Jadval). Prefs'da saqlanadi.
final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, TrainingSchedule>(
      (ref) => ScheduleNotifier(ref),
    );

class ScheduleNotifier extends StateNotifier<TrainingSchedule> {
  ScheduleNotifier(this._ref) : super(_load(_ref));

  final Ref _ref;

  static TrainingSchedule _load(Ref ref) {
    final raw = ref.read(sharedPrefsProvider).getString(_scheduleKey);
    if (raw == null) return const TrainingSchedule();
    try {
      return TrainingSchedule.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return const TrainingSchedule();
    }
  }

  void set(TrainingSchedule s) {
    state = s;
    _ref
        .read(sharedPrefsProvider)
        .setString(_scheduleKey, jsonEncode(s.toJson()));
  }

  void toggleDay(int weekday) {
    final days = {...state.weekdays};
    if (!days.remove(weekday)) days.add(weekday);
    if (days.isEmpty) return; // kamida bitta kun
    set(state.copyWith(weekdays: days));
  }
}

/// Bugungi holat — Home'dagi "Bugungi vazifa" kartasi uchun.
enum MissionState { todo, done, rest }

class Discipline {
  const Discipline({
    required this.state,
    required this.streak,
    required this.bestStreak,
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.nextLevelXp,
    required this.weekDone,
    required this.weekPlanned,
    required this.totalWorkouts,
    required this.totalKcal,
    required this.totalKm,
  });

  final MissionState state;
  final int streak;
  final int bestStreak;
  final int xp;
  final int level;
  final double levelProgress;
  final int nextLevelXp;

  /// Shu hafta (dushanbadan) bajarilgan / rejalashtirilgan mashg'ulot kunlari.
  final int weekDone;
  final int weekPlanned;

  final int totalWorkouts;
  final int totalKcal;
  final double totalKm;
}

/// Mashg'ulot qilingan kunlar (00:00 ga keltirilgan).
final workoutDaysProvider = Provider<Set<DateTime>>(
  (ref) => {for (final e in ref.watch(workoutLogProvider)) dayOf(e.date)},
);

final disciplineProvider = Provider<Discipline>((ref) {
  final log = ref.watch(workoutLogProvider);
  final schedule = ref.watch(scheduleProvider);
  final now = DateTime.now();
  final today = dayOf(now);
  final days = ref.watch(workoutDaysProvider);
  final totalKcal = log.fold(0, (s, e) => s + e.kcal);
  final xp = xpFor(workouts: log.length, totalKcal: totalKcal);
  final lv = levelFor(xp);

  final monday = today.subtract(Duration(days: today.weekday - 1));
  final weekDays = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];

  return Discipline(
    state: days.contains(today)
        ? MissionState.done
        : schedule.isTrainingDay(today)
        ? MissionState.todo
        : MissionState.rest,
    streak: scheduleStreak(workoutDays: days, schedule: schedule, today: now),
    bestStreak: longestDailyStreak(days),
    xp: xp,
    level: lv.level,
    levelProgress: lv.progress,
    nextLevelXp: lv.nextAt,
    weekDone: weekDays.where(days.contains).length,
    weekPlanned: weekDays.where(schedule.isTrainingDay).length,
    totalWorkouts: log.length,
    totalKcal: totalKcal,
    totalKm: log.fold(0.0, (s, e) => s + (e.distanceKm ?? 0)),
  );
});

/// Yutuqlar (nishonlar).
class Achievement {
  const Achievement(this.id, this.icon, this.unlocked, this.progress);

  final String id;
  final IconData icon;
  final bool unlocked;

  /// 0..1 — ochilmaganlar uchun qancha qolgani.
  final double progress;
}

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final d = ref.watch(disciplineProvider);
  Achievement a(String id, IconData icon, num value, num goal) => Achievement(
    id,
    icon,
    value >= goal,
    (value / goal).clamp(0, 1).toDouble(),
  );
  return [
    a('first', Icons.flag_rounded, d.totalWorkouts, 1),
    a('streak3', Icons.local_fire_department_rounded, d.bestStreak, 3),
    a('streak7', Icons.whatshot_rounded, d.bestStreak, 7),
    a('workouts10', Icons.fitness_center_rounded, d.totalWorkouts, 10),
    a('workouts50', Icons.military_tech_rounded, d.totalWorkouts, 50),
    a('kcal5000', Icons.bolt_rounded, d.totalKcal, 5000),
    a('km10', Icons.directions_run_rounded, d.totalKm, 10),
    a('level5', Icons.emoji_events_rounded, d.level, 5),
  ];
});

/// Jadval, bugungi holat yoki til o'zgarsa — eslatmalar qayta rejalashtiriladi.
/// Bugun mashg'ulot qilinsa, kechki "seriyani saqla" eslatmasi avtomatik bekor bo'ladi.
final reminderSyncProvider = Provider<void>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final doneToday = ref.watch(
    disciplineProvider.select((d) => d.state == MissionState.done),
  );
  final streak = ref.watch(disciplineProvider.select((d) => d.streak));
  final locale = ref.watch(localeProvider);
  // Ishga tushishni sekinlatmaslik va ketma-ket o'zgarishlarni birlashtirish uchun
  // 2 soniya kutiladi; shu orada qiymat o'zgarsa — eski taymer bekor qilinadi.
  final timer = Timer(const Duration(seconds: 2), () {
    ReminderService.instance.reschedule(
      schedule: schedule,
      doneToday: doneToday,
      streak: streak,
      locale: locale,
    );
  });
  ref.onDispose(timer.cancel);
});

/// Avtomatik tavsiya: hafta kuniga qarab tayyor mashg'ulotlardan biri (Home bilan bir xil).
final autoRoutineProvider = Provider.family<Routine, int>((ref, weekday) {
  final routines = ref
      .watch(routinesProvider)
      .where((r) => !r.isCustom)
      .toList();
  return routines[weekday % routines.length];
});

/// "Bugungi vazifa" kartasi yig'ilganmi (foydalanuvchi tanlovi, saqlanadi).
final missionCollapsedProvider =
    StateNotifierProvider<MissionCollapsedNotifier, bool>(
      (ref) => MissionCollapsedNotifier(ref),
    );

class MissionCollapsedNotifier extends StateNotifier<bool> {
  MissionCollapsedNotifier(this._ref)
    : super(_ref.read(sharedPrefsProvider).getBool(_key) ?? true);

  static const _key = 'mission_collapsed';
  final Ref _ref;

  void toggle() {
    state = !state;
    _ref.read(sharedPrefsProvider).setBool(_key, state);
  }
}
