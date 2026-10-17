import 'package:fitness_app/features/motivation/data/discipline.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-10-12 — dushanba.
DateTime d(int day) => DateTime(2026, 10, day, 18);

void main() {
  const monWedFri = TrainingSchedule(weekdays: {1, 3, 5});

  test('dam olish kunlari seriyani uzmaydi', () {
    // Du(12), Chor(14), Ju(16) bajarilgan; bugun — Shanba(17), dam olish.
    final s = scheduleStreak(
      workoutDays: {d(12), d(14), d(16)},
      schedule: monWedFri,
      today: d(17),
    );
    expect(s, 3);
  });

  test('rejalashtirilgan kun o\'tkazib yuborilsa — seriya uziladi', () {
    // Du(12) bajarilgan, Chor(14) — YO'Q, Ju(16) bajarilgan.
    final s = scheduleStreak(
      workoutDays: {d(12), d(16)},
      schedule: monWedFri,
      today: d(17),
    );
    expect(s, 1);
  });

  test('bugun hali bajarilmagan — seriya uzilmaydi', () {
    // Bugun Ju(16), mashg'ulot kuni, hali qilinmagan; Du va Chor bajarilgan.
    final s = scheduleStreak(
      workoutDays: {d(12), d(14)},
      schedule: monWedFri,
      today: d(16),
    );
    expect(s, 2);
  });

  test('dam olish kunidagi qo\'shimcha mashg\'ulot — bonus', () {
    final s = scheduleStreak(
      workoutDays: {d(12), d(13), d(14)},
      schedule: monWedFri,
      today: d(15),
    );
    expect(s, 3);
  });

  test('eng uzun kunlik seriya', () {
    expect(longestDailyStreak({d(1), d(2), d(3), d(5), d(6)}), 3);
    expect(longestDailyStreak({}), 0);
  });

  test('XP va daraja', () {
    expect(xpFor(workouts: 2, totalKcal: 500), 200);
    expect(levelFor(0).level, 1);
    expect(levelFor(150).level, 2);
    expect(levelFor(600).level, 3);
    final l = levelFor(300);
    expect(l.level, 2);
    expect(l.progress, closeTo(0.333, 0.01));
  });

  test('jadval JSON', () {
    const s = TrainingSchedule(
      weekdays: {2, 4},
      hour: 7,
      minute: 30,
      enabled: true,
    );
    final back = TrainingSchedule.fromJson(s.toJson());
    expect(back.weekdays, {2, 4});
    expect(back.hour, 7);
    expect(back.enabled, isTrue);
  });

  test(
    "kun bo'yicha vazifa: tanlansa — mashg'ulot kuniga aylanadi, JSON saqlanadi",
    () {
      const s = TrainingSchedule(weekdays: {1, 3});
      final withBb = s.withPlan(6, MissionPlan.bodybuilding);
      expect(withBb.weekdays, {1, 3, 6});
      expect(withBb.plans[6], 'bb');
      final back = TrainingSchedule.fromJson(withBb.toJson());
      expect(back.plans, {6: 'bb'});
      expect(back.withPlan(6, null).plans, isEmpty);
      expect(MissionPlan.routineId(MissionPlan.routine('b1')), 'b1');
      expect(MissionPlan.routineId('run'), isNull);
    },
  );
}
