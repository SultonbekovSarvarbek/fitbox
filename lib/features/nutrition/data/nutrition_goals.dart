import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../setup/setup_profile.dart';

/// Kunlik ovqatlanish me'yori.
typedef DailyTargets = ({int kcal, int protein, int carbs, int fat});

/// Foydalanuvchi ma'lumotlaridan kunlik me'yor:
///
/// 1. BMR — Mifflin–St Jeor: 10·vazn + 6.25·bo'y − 5·yosh + (erkak +5 / ayol −161)
/// 2. × faollik koeffitsienti (boshlang'ich 1.375 · o'rta 1.55 · yuqori 1.725)
/// 3. ± maqsad: vazn yo'qotish −500, vazn olish +300, mushak +250 kkal
/// 4. Makrolar: oqsil 1.8 g/kg (ozishda 2.0), yog' — 25% kaloriya, qolgani uglevod.
/// Faollik koeffitsienti: haftalik mashg'ulot kunlari bo'yicha (0 kun — kam harakat),
/// kardio/yugurish/HIIT bo'lsa biroz yuqoriroq (ular ko'proq kaloriya yoqadi).
double activityFactorFor(SetupProfile u) {
  final base = switch (u.trainingDays) {
    0 => 1.2,
    1 || 2 => 1.375,
    3 || 4 => 1.55,
    5 || 6 => 1.725,
    _ => 1.9,
  };
  const heavy = {TrainingType.cardio, TrainingType.running, TrainingType.hiit};
  final bonus = u.trainingDays > 0 && u.trainingTypes.any(heavy.contains)
      ? 0.03
      : 0.0;
  return base + bonus;
}

/// Kunlik umumiy sarf (TDEE) — Mifflin–St Jeor BMR × faollik koeffitsienti.
double tdeeFor(SetupProfile u) {
  final bmr =
      10 * u.weightKg +
      6.25 * u.heightCm -
      5 * u.age +
      (u.gender == Gender.male ? 5 : -161);
  return bmr * activityFactorFor(u);
}

/// Haftalik mashg'ulot kaloriyasi maqsadi — shaxsiy: TDEE × 7 × ulush.
/// Ulush: ozish 15%, mushak/qomat 10%, vazn olish/boshqa 7%. 50 ga yaxlitlanadi.
int weeklyBurnGoalFor(SetupProfile u) {
  final share = switch (u.goal) {
    Goal.loseWeight => 0.15,
    Goal.muscleMass || Goal.shapeBody => 0.10,
    Goal.gainWeight || Goal.others => 0.07,
  };
  return ((tdeeFor(u) * 7 * share) / 50).round() * 50;
}

DailyTargets dailyTargetsFor(SetupProfile u) {
  final adjust = switch (u.goal) {
    Goal.loseWeight => -500,
    Goal.gainWeight => 300,
    Goal.muscleMass => 250,
    Goal.shapeBody || Goal.others => 0,
  };
  final kcal = (tdeeFor(u) + adjust).clamp(1200, 4500).round();
  final protein = (u.weightKg * (u.goal == Goal.loseWeight ? 2.0 : 1.8))
      .round();
  final fat = (kcal * 0.25 / 9).round();
  final carbs = ((kcal - protein * 4 - fat * 9) / 4).round().clamp(50, 1000);
  return (kcal: kcal, protein: protein, carbs: carbs, fat: fat);
}

final dailyTargetsProvider = Provider<DailyTargets>(
  (ref) => dailyTargetsFor(ref.watch(userProvider)),
);
