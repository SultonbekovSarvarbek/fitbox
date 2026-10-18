import 'package:fitness_app/core/audience.dart';
import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/product_info.dart';
import 'package:fitness_app/features/market/data/sports_recommendation.dart';
import 'package:fitness_app/features/news/data/news_models.dart';
import 'package:fitness_app/features/news/news_screen.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

SetupProfile person(
  Gender gender, {
  Goal goal = Goal.shapeBody,
  int days = 3,
  Set<TrainingType> types = const {TrainingType.strength},
}) => SetupProfile()
  ..gender = gender
  ..goal = goal
  ..trainingDays = days
  ..trainingTypes = {...types};

void main() {
  group('visibility rules', () {
    test('"for everyone" is always visible', () {
      for (final f in AudienceFilter.values) {
        expect(audienceVisible(Audience.everyone, f), isTrue);
      }
    });

    test('men and women items only show in their own filter and in All', () {
      expect(audienceVisible(Audience.men, AudienceFilter.men), isTrue);
      expect(audienceVisible(Audience.men, AudienceFilter.women), isFalse);
      expect(audienceVisible(Audience.men, AudienceFilter.all), isTrue);
      expect(audienceVisible(Audience.women, AudienceFilter.women), isTrue);
      expect(audienceVisible(Audience.women, AudienceFilter.men), isFalse);
      expect(audienceVisible(Audience.women, AudienceFilter.all), isTrue);
    });

    test('default filter follows the profile gender', () {
      expect(audienceFilterFor(Gender.male), AudienceFilter.men);
      expect(audienceFilterFor(Gender.female), AudienceFilter.women);
    });

    test('specific-to-gender means exactly that gender', () {
      expect(audienceIsSpecificTo(Audience.men, Gender.male), isTrue);
      expect(audienceIsSpecificTo(Audience.women, Gender.male), isFalse);
      expect(audienceIsSpecificTo(Audience.everyone, Gender.female), isFalse);
    });
  });

  group('shop', () {
    test(
      'there are products for women and for men, and the rest for everyone',
      () {
        expect(
          products.where((p) => p.audience == Audience.women).length,
          greaterThanOrEqualTo(3),
        );
        expect(
          products.where((p) => p.audience == Audience.men).length,
          greaterThanOrEqualTo(3),
        );
        expect(
          products.where((p) => p.audience == Audience.everyone),
          isNotEmpty,
        );
      },
    );

    test('every gender-specific product has a full product page', () {
      for (final p in products.where((p) => p.audience != Audience.everyone)) {
        final i = productInfo[p.id];
        expect(i, isNotNull, reason: p.id);
        expect(i!.contraindications, isNotEmpty, reason: p.id);
        expect(i.howToUse, isNotEmpty, reason: p.id);
      }
    });

    test('product ids are unique', () {
      final ids = products.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('recommended products never cross over to the other gender', () {
      for (final g in Goal.values) {
        expect(
          recommendProducts(
            g,
            gender: Gender.male,
          ).where((p) => p.audience == Audience.women),
          isEmpty,
          reason: 'men / ${g.name}',
        );
        expect(
          recommendProducts(
            g,
            gender: Gender.female,
          ).where((p) => p.audience == Audience.men),
          isEmpty,
          reason: 'women / ${g.name}',
        );
      }
    });

    test(
      'products made for the gender are visible, main ones are not pushed out',
      () {
        final m = recommendProducts(Goal.muscleMass, gender: Gender.male);
        expect(m.any((p) => p.audience == Audience.men), isTrue);
        // Asosiy mahsulotlar (protein, kreatin) ro'yxatda qoladi.
        expect(m.any((p) => p.category == ProductCategory.protein), isTrue);
        expect(m.any((p) => p.id == 'creatine'), isTrue);

        final w = recommendProducts(Goal.loseWeight, gender: Gender.female);
        expect(w.first.audience, Audience.women);
      },
    );
  });

  group('meal programs', () {
    test('there are programs for women and for men', () {
      expect(
        mealPlans.where((p) => p.audience == Audience.women).length,
        greaterThanOrEqualTo(2),
      );
      expect(
        mealPlans.where((p) => p.audience == Audience.men).length,
        greaterThanOrEqualTo(2),
      );
    });

    test('a woman is never offered a men-only program and vice versa', () {
      for (final kcal in [1200, 1600, 2000, 2500, 3000]) {
        for (final g in Goal.values) {
          expect(
            recommendPlans(
              targetKcal: kcal,
              goal: g,
              gender: Gender.female,
            ).where((p) => p.audience == Audience.men),
            isEmpty,
          );
          expect(
            recommendPlans(
              targetKcal: kcal,
              goal: g,
              gender: Gender.male,
            ).where((p) => p.audience == Audience.women),
            isEmpty,
          );
        }
      }
    });

    test(
      'calories still decide: a woman who needs 3000 kcal gets a big program',
      () {
        final r = recommendPlans(
          targetKcal: 3000,
          goal: Goal.gainWeight,
          gender: Gender.female,
        );
        expect(r.first.kcal, greaterThanOrEqualTo(2500));
      },
    );

    test('with equal fit, the program made for the gender wins', () {
      final f = recommendPlans(
        targetKcal: 1500,
        goal: Goal.loseWeight,
        gender: Gender.female,
      );
      expect(f.first.audience, Audience.women);
      final m = recommendPlans(
        targetKcal: 2400,
        goal: Goal.shapeBody,
        gender: Gender.male,
      );
      expect(m.first.audience, Audience.men);
    });
  });

  group('personal recommendation', () {
    Product protein(SetupProfile u) => recommendFor(u).supplements
        .firstWhere((s) => s.product.category == ProductCategory.protein)
        .product;

    test('a man who is cutting gets the isolate, not a mass protein', () {
      final p = protein(person(Gender.male, goal: Goal.loseWeight));
      expect(p.goals, contains(Goal.loseWeight));
      expect(p.audience, isNot(Audience.women));
    });

    test('a man building muscle gets the protein made for men', () {
      expect(
        protein(person(Gender.male, goal: Goal.muscleMass)).id,
        'm-whey-power',
      );
    });

    test('a woman who is cutting gets the light whey for women', () {
      expect(
        protein(person(Gender.female, goal: Goal.loseWeight)).id,
        'w-whey-lite',
      );
    });

    test('nothing for the other gender ever appears', () {
      for (final g in Goal.values) {
        for (final types in [
          {TrainingType.strength},
          {TrainingType.running, TrainingType.teamSports},
        ]) {
          final men = recommendFor(
            person(Gender.male, goal: g, days: 5, types: types),
          );
          final women = recommendFor(
            person(Gender.female, goal: g, days: 5, types: types),
          );
          expect(
            men.supplements.any((s) => s.product.audience == Audience.women),
            isFalse,
          );
          expect(
            women.supplements.any((s) => s.product.audience == Audience.men),
            isFalse,
          );
          expect(men.plans.any((p) => p.audience == Audience.women), isFalse);
          expect(women.plans.any((p) => p.audience == Audience.men), isFalse);
        }
      }
    });

    test('vitamins: each gender gets its own complex when training hard', () {
      Product vit(Gender g) => recommendFor(person(g, days: 5)).supplements
          .firstWhere((s) => s.product.category == ProductCategory.vitamins)
          .product;
      expect(vit(Gender.female).audience, Audience.women);
      expect(vit(Gender.male).audience, Audience.men);
    });
  });

  group('news', () {
    test('both audiences have their own articles', () {
      expect(
        news.where((n) => n.audience == Audience.women).length,
        greaterThanOrEqualTo(3),
      );
      expect(
        news.where((n) => n.audience == Audience.men).length,
        greaterThanOrEqualTo(3),
      );
    });

    test('filter keeps general articles and the chosen gender only', () {
      final women = newsSorted(null, AudienceFilter.women);
      expect(women.any((n) => n.audience == Audience.men), isFalse);
      expect(women.any((n) => n.audience == Audience.women), isTrue);
      expect(women.any((n) => n.audience == Audience.everyone), isTrue);

      final men = newsSorted(null, AudienceFilter.men);
      expect(men.any((n) => n.audience == Audience.women), isFalse);
      expect(men.any((n) => n.audience == Audience.men), isTrue);

      expect(newsSorted().length, news.length);
    });

    test('"read next" of a women article never suggests a men article', () {
      for (final n in news.where((n) => n.audience == Audience.women)) {
        expect(
          relatedNews(n).any((r) => r.audience == Audience.men),
          isFalse,
          reason: n.id,
        );
      }
      for (final n in news.where((n) => n.audience == Audience.men)) {
        expect(
          relatedNews(n).any((r) => r.audience == Audience.women),
          isFalse,
          reason: n.id,
        );
      }
    });

    test('every category still has enough articles for each audience', () {
      for (final f in [AudienceFilter.men, AudienceFilter.women]) {
        final items = newsSorted(null, f);
        expect(items.length, greaterThanOrEqualTo(15), reason: f.name);
      }
    });
  });

  group('news screen switch', () {
    Future<void> pump(WidgetTester tester, Gender gender) async {
      tester.view
        ..physicalSize = const Size(900, 3000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(userProvider.notifier).state = SetupProfile()
        ..gender = gender;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(path: '/', builder: (_, _) => const NewsScreen()),
              ],
            ),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a man starts with men articles and can switch to women', (
      tester,
    ) async {
      await pump(tester, Gender.male);
      // Faqat "Sport" tabida, ro'yxat qisqa bo'lsin.
      await tester.tap(find.text('Sport').first);
      await tester.pumpAndSettle();
      expect(
        find.text('Men over 35: keeping muscle and energy'),
        findsOneWidget,
      );
      expect(
        find.text('Strength training for women: you will not get bulky'),
        findsNothing,
      );

      await tester.tap(find.text('For women'));
      await tester.pumpAndSettle();
      expect(find.text('Men over 35: keeping muscle and energy'), findsNothing);
      expect(
        find.text('Strength training for women: you will not get bulky'),
        findsOneWidget,
      );

      await tester.tap(find.text('All').first);
      await tester.pumpAndSettle();
      expect(
        find.text('Men over 35: keeping muscle and energy'),
        findsOneWidget,
      );
      expect(
        find.text('Strength training for women: you will not get bulky'),
        findsOneWidget,
      );
    });

    testWidgets('a woman starts with women articles', (tester) async {
      await pump(tester, Gender.female);
      await tester.tap(find.text('Sport').first);
      await tester.pumpAndSettle();
      expect(
        find.text('Strength training for women: you will not get bulky'),
        findsOneWidget,
      );
      expect(find.text('Men over 35: keeping muscle and energy'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
