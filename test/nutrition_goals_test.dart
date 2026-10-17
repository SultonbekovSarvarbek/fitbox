import 'package:fitness_app/features/nutrition/data/nutrition_goals.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:flutter_test/flutter_test.dart';

SetupProfile person({
  Gender gender = Gender.male,
  int age = 25,
  int weight = 70,
  int height = 170,
  Goal goal = Goal.shapeBody,
}) => SetupProfile()
  ..gender = gender
  ..age = age
  ..weightKg = weight
  ..heightCm = height
  ..goal = goal
  ..activity = ActivityLevel.beginner
  // 1–2 kun/hafta — koeffitsient 1.375 (eski "boshlang'ich" bilan bir xil).
  ..trainingDays = 2
  ..trainingTypes = {TrainingType.strength};

void main() {
  test('TDEE — Mifflin–St Jeor', () {
    // 10·70 + 6.25·170 − 5·25 + 5 = 1642.5; × 1.375 = 2258.4
    expect(tdeeFor(person()), closeTo(2258.4, 0.1));
  });

  test('faollik koeffitsienti haftalik mashg\'ulot kunlariga bog\'liq', () {
    double factor(int days, [Set<TrainingType>? types]) => activityFactorFor(
      person()
        ..trainingDays = days
        ..trainingTypes = types ?? {TrainingType.strength},
    );
    expect(factor(0), 1.2);
    expect(factor(2), 1.375);
    expect(factor(4), 1.55);
    expect(factor(6), 1.725);
    expect(factor(7), 1.9);
    // Kardio/yugurish/HIIT — +0.03; mashg'ulot yo'q bo'lsa qo'shilmaydi.
    expect(factor(4, {TrainingType.running}), closeTo(1.58, 1e-9));
    expect(factor(0, {TrainingType.running}), 1.2);
  });

  test('haftalik maqsad shaxsiy — vazn, jins, maqsadga qarab farq qiladi', () {
    final base = weeklyBurnGoalFor(person()); // 2258 × 7 × 10% ≈ 1600
    expect(base, 1600);
    expect(weeklyBurnGoalFor(person(weight: 95)), greaterThan(base));
    expect(
      weeklyBurnGoalFor(person(gender: Gender.female, weight: 55, height: 160)),
      lessThan(base),
    );
    expect(weeklyBurnGoalFor(person(goal: Goal.loseWeight)), greaterThan(base));
    expect(weeklyBurnGoalFor(person(age: 55)), lessThan(base));
  });
}
