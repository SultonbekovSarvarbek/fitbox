import 'dart:convert';

import 'package:fitness_app/core/audience.dart';
import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/home/main_screen.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/subscription_models.dart';
import 'package:fitness_app/features/market/market_screen.dart'
    show BestPlanCard, PlanTile, ProductCard;
import 'package:fitness_app/features/profile/edit_profile_screen.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pump(
  WidgetTester tester, {
  required Gender gender,
  Goal goal = Goal.shapeBody,
  Map<String, Object> prefs = const {},
  Widget home = const MainScreen(),
}) async {
  tester.view
    ..physicalSize = const Size(1400, 3600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(sp)],
  );
  addTearDown(container.dispose);
  container.read(userProvider.notifier).state = SetupProfile()
    ..gender = gender
    ..goal = goal
    ..fullName = 'Aziz Karimov'
    ..nickname = 'Aziz';

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(path: '/edit', builder: (_, _) => const EditProfileScreen()),
      GoRoute(
        path: '/shop',
        builder: (_, _) => const Scaffold(body: Text('SHOP TAB')),
      ),
      GoRoute(
        path: '/subscription',
        builder: (_, _) => const Scaffold(body: Text('SUBSCRIPTION TAB')),
      ),
      GoRoute(
        path: '/market/cart',
        builder: (_, _) => const Scaffold(body: Text('CART')),
      ),
      GoRoute(
        path: '/market/product/:id',
        builder: (_, s) =>
            Scaffold(body: Text('PRODUCT ${s.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/subscribe/:plan',
        builder: (_, s) =>
            Scaffold(body: Text('SUBSCRIBE ${s.pathParameters['plan']}')),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

List<Product> shownProducts(WidgetTester tester) => [
  for (final w in tester.widgetList<ProductCard>(find.byType(ProductCard)))
    w.product,
];

List<MealPlanOffer> shownPlans(WidgetTester tester) => [
  for (final w in tester.widgetList<BestPlanCard>(find.byType(BestPlanCard)))
    w.plan,
  for (final w in tester.widgetList<PlanTile>(find.byType(PlanTile))) w.plan,
];

void main() {
  group('home screen follows the gender chosen at registration', () {
    testWidgets('a man sees men sports nutrition and men programs', (
      tester,
    ) async {
      await pump(tester, gender: Gender.male);

      expect(find.text('Hi, Aziz'), findsOneWidget);
      expect(find.text('Picked for men'), findsOneWidget);
      expect(find.text('Sports nutrition for men'), findsOneWidget);
      expect(find.text('Meal subscription'), findsOneWidget);

      final products = shownProducts(tester);
      expect(products, isNotEmpty);
      expect(products.any((p) => p.audience == Audience.men), isTrue);
      expect(products.any((p) => p.audience == Audience.women), isFalse);

      final plans = shownPlans(tester);
      expect(plans, isNotEmpty);
      expect(plans.any((p) => p.audience == Audience.women), isFalse);
      expect(find.byType(BestPlanCard), findsOneWidget);
    });

    testWidgets('a woman sees women sports nutrition and women programs', (
      tester,
    ) async {
      await pump(tester, gender: Gender.female);

      expect(find.text('Picked for women'), findsOneWidget);
      expect(find.text('Sports nutrition for women'), findsOneWidget);

      final products = shownProducts(tester);
      expect(products.any((p) => p.audience == Audience.women), isTrue);
      expect(products.any((p) => p.audience == Audience.men), isFalse);

      final plans = shownPlans(tester);
      expect(plans.any((p) => p.audience == Audience.men), isFalse);
    });

    testWidgets('both products and a subscription are on the same screen', (
      tester,
    ) async {
      await pump(tester, gender: Gender.female, goal: Goal.loseWeight);
      expect(find.byType(ProductCard), findsWidgets);
      expect(find.byType(BestPlanCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same user always sees only items fit for the gender', (
      tester,
    ) async {
      for (final g in Gender.values) {
        for (final goal in Goal.values) {
          await pump(tester, gender: g, goal: goal);
          final bad = g == Gender.male ? Audience.women : Audience.men;
          expect(
            shownProducts(tester).any((p) => p.audience == bad),
            isFalse,
            reason: '${g.name}/${goal.name} products',
          );
          expect(
            shownPlans(tester).any((p) => p.audience == bad),
            isFalse,
            reason: '${g.name}/${goal.name} plans',
          );
        }
      }
    });

    testWidgets('"See all" opens the shop and the subscription tab', (
      tester,
    ) async {
      await pump(tester, gender: Gender.male);
      final seeAll = find.text('See all');
      expect(seeAll, findsNWidgets(2));
      await tester.tap(seeAll.first);
      await tester.pumpAndSettle();
      expect(find.text('SHOP TAB'), findsOneWidget);
    });

    testWidgets('tapping a product or a program opens it', (tester) async {
      await pump(tester, gender: Gender.male);
      await tester.tap(find.byType(ProductCard).first);
      await tester.pumpAndSettle();
      expect(find.textContaining('PRODUCT '), findsOneWidget);
    });

    testWidgets('an active subscription replaces the offer', (tester) async {
      final sub = Subscription(
        id: 'SUB-9',
        createdAt: DateTime.now(),
        planId: 'he-2400',
        months: 1,
        slots: {MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner},
        startDate: DateUtils.dateOnly(
          DateTime.now(),
        ).subtract(const Duration(days: 2)),
        address: 'Chilonzor 5',
        phone: '+998901234567',
        total: 3000000,
        payment: PaymentMethod.cash,
      );
      await pump(
        tester,
        gender: Gender.male,
        prefs: {
          'subscriptions': jsonEncode([sub.toJson()]),
        },
      );
      expect(find.byType(BestPlanCard), findsNothing);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Strong & Fit'), findsOneWidget);
    });
  });

  group('changing the gender later', () {
    testWidgets('edit profile: switch to female and save', (tester) async {
      final c = await pump(
        tester,
        gender: Gender.male,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/edit'),
              child: const Text('open'),
            ),
          ),
        ),
      );
      expect(c.read(userProvider).gender, Gender.male);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final u = c.read(userProvider);
      expect(u.gender, Gender.female);
      // Anketaning boshqa maydonlari yo'qolmaydi.
      expect(u.fullName, 'Aziz Karimov');
      expect(u.trainingDays, 3);
    });
  });
}
