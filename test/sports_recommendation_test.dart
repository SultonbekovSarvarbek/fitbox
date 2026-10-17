import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/sports_recommendation.dart';
import 'package:fitness_app/features/market/data/subscription_models.dart';
import 'package:fitness_app/features/nutrition/data/nutrition_goals.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:flutter_test/flutter_test.dart';

SetupProfile profile({
  required Goal goal,
  int days = 3,
  Set<TrainingType> types = const {TrainingType.strength},
  int weight = 75,
  int age = 25,
}) => SetupProfile()
  ..goal = goal
  ..trainingDays = days
  ..trainingTypes = {...types}
  ..weightKg = weight
  ..age = age;

Set<ProductCategory> cats(NutritionRecommendation r) => {
  for (final s in r.supplements) s.product.category,
};

void main() {
  group('tdee depends on the training week', () {
    test('more training days -> higher daily need', () {
      final none = tdeeFor(profile(goal: Goal.shapeBody, days: 0));
      final some = tdeeFor(profile(goal: Goal.shapeBody, days: 3));
      final lots = tdeeFor(profile(goal: Goal.shapeBody, days: 6));
      expect(none, lessThan(some));
      expect(some, lessThan(lots));
    });

    test('cardio/running adds a little', () {
      final lift = tdeeFor(profile(goal: Goal.shapeBody, days: 4));
      final run = tdeeFor(
        profile(goal: Goal.shapeBody, days: 4, types: {TrainingType.running}),
      );
      expect(run, greaterThan(lift));
    });
  });

  group('recommendFor', () {
    test('lifter building muscle gets protein and creatine', () {
      final r = recommendFor(profile(goal: Goal.muscleMass, days: 4));
      expect(
        cats(r),
        containsAll([ProductCategory.protein, ProductCategory.creatine]),
      );
    });

    test('cutting prefers the isolate', () {
      final r = recommendFor(profile(goal: Goal.loseWeight));
      final protein = r.supplements.firstWhere(
        (s) => s.product.category == ProductCategory.protein,
      );
      expect(protein.product.goals, contains(Goal.loseWeight));
    });

    test('gaining weight gets a gainer, not creatine for a yoga-only week', () {
      final gain = recommendFor(profile(goal: Goal.gainWeight));
      expect(cats(gain), contains(ProductCategory.gainer));

      final yoga = recommendFor(
        profile(goal: Goal.muscleMass, days: 3, types: {TrainingType.yoga}),
      );
      expect(cats(yoga), isNot(contains(ProductCategory.creatine)));
    });

    test('runner gets aminos and bars', () {
      final r = recommendFor(
        profile(goal: Goal.shapeBody, days: 4, types: {TrainingType.running}),
      );
      expect(
        cats(r),
        containsAll([ProductCategory.aminos, ProductCategory.bars]),
      );
    });

    test('every pick has a reason and meal plans are suggested', () {
      final r = recommendFor(profile(goal: Goal.shapeBody));
      expect(r.supplements, isNotEmpty);
      expect(r.plans, isNotEmpty);
      for (final s in r.supplements) {
        expect(s.reason.en, isNotEmpty);
        expect(s.reason.uz, isNotEmpty);
        expect(s.reason.ru, isNotEmpty);
      }
    });

    test('no training and no goal -> no pushy supplements', () {
      final r = recommendFor(profile(goal: Goal.others, days: 0));
      expect(cats(r), isNot(contains(ProductCategory.creatine)));
    });
  });

  group('subscriptionPrice', () {
    final plan = mealPlans.first;

    test('one month, three meals = daily price x 30', () {
      final p = subscriptionPrice(plan, months: 1, slots: 3);
      expect(p.days, 30);
      expect(p.discount, 0);
      expect(p.total, plan.pricePerDay * 30);
    });

    test('three months gets the discount', () {
      final one = subscriptionPrice(plan, months: 1, slots: 3);
      final three = subscriptionPrice(plan, months: 3, slots: 3);
      expect(three.discount, greaterThan(0));
      expect(three.total, lessThan(one.total * 3));
    });

    test('fewer meals cost less', () {
      final all = subscriptionPrice(plan, months: 1, slots: 3).total;
      final one = subscriptionPrice(plan, months: 1, slots: 1).total;
      expect(one, lessThan(all));
    });
  });

  test('subscription survives a json round trip', () {
    final s = Subscription(
      id: 'SUB-1',
      createdAt: DateTime(2026, 10, 17),
      planId: 'balance-1600',
      months: 3,
      slots: {MealSlot.breakfast, MealSlot.dinner},
      startDate: DateTime(2026, 10, 18),
      address: 'Chilonzor 5',
      phone: '+998901234567',
      total: 1000000,
      payment: PaymentMethod.click,
    );
    final back = Subscription.fromJson(s.toJson());
    expect(back.slots, s.slots);
    expect(back.months, 3);
    expect(back.payment, PaymentMethod.click);
    expect(back.plan?.id, 'balance-1600');
  });

  test('profile keeps the training week through json', () {
    final p = profile(
      goal: Goal.muscleMass,
      days: 5,
      types: {TrainingType.strength, TrainingType.running},
    );
    final back = SetupProfile.fromJson(p.toJson());
    expect(back.trainingDays, 5);
    expect(back.trainingTypes, p.trainingTypes);
  });
}
