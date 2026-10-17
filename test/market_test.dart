import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ozish, 1 250 kkal → eng mos — 1200 kkal ozish ratsioni', () {
    final r = recommendPlans(targetKcal: 1250, goal: Goal.loseWeight);
    expect(r.first.id, 'slim-1200');
    expect(r.every((x) => x.goals.contains(Goal.loseWeight)), isTrue);
  });

  test('massa, 2 600 kkal → massa ratsioni', () {
    final r = recommendPlans(targetKcal: 2600, goal: Goal.muscleMass);
    expect(r.first.id, 'mass-2500');
  });

  test('vazn olish → gainer tavsiya qilinadi, ozishda — yo\'q', () {
    expect(
      recommendProducts(Goal.gainWeight).map((p) => p.id),
      contains('gainer'),
    );
    expect(
      recommendProducts(Goal.loseWeight).map((p) => p.id),
      isNot(contains('gainer')),
    );
  });

  group('bitta oshxona', () {
    test('ratsion id lari takrorlanmaydi va narxlari tartibli', () {
      final ids = mealPlans.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final p in mealPlans) {
        expect(p.pricePerDay, greaterThan(0), reason: p.id);
        expect(p.menu, isNotEmpty, reason: p.id);
        expect(p.tagline.ru, isNotEmpty, reason: p.id);
      }
    });

    test('har bir maqsad uchun kamida bitta mos ratsion bor', () {
      for (final g in Goal.values) {
        expect(
          mealPlans.any((p) => p.goals.contains(g)),
          isTrue,
          reason: g.name,
        );
      }
    });

    test('eski id bilan saqlangan obuna yangi ratsionni topadi', () {
      expect(mealPlanById('fitbox-1600')?.id, 'balance-1600');
      expect(mealPlanById('pk-3000')?.id, 'bulk-3000');
      expect(mealPlanById('balance-1600')?.id, 'balance-1600');
      expect(mealPlanById('nope'), isNull);
    });

    test(
      'kaloriya va maqsad ratsionga aynan mos kelsa — shu ratsion birinchi',
      () {
        for (final plan in mealPlans) {
          for (final goal in plan.goals) {
            final r = recommendPlans(targetKcal: plan.kcal, goal: goal);
            expect(r.first.id, plan.id, reason: '${plan.id} / ${goal.name}');
          }
        }
      },
    );
  });

  test(
    'norma 2546 kkal, maqsad "qomatni shakllantirish" -> ~2500 kkal ratsion',
    () {
      // Avval maqsad jarimasi kaloriyadan ustun kelib, 2000 kkalli ratsion chiqardi.
      final r = recommendPlans(targetKcal: 2546, goal: Goal.shapeBody);
      expect(r.first.id, 'mass-2500');
    },
  );
}
