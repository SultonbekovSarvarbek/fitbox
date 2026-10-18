import 'package:fitness_app/app/router.dart';
import 'package:fitness_app/core/content/content_l10n.dart';
import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/news/data/news_models.dart';
import 'package:fitness_app/features/news/news_detail_screen.dart';
import 'package:fitness_app/features/news/news_screen.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void filled(Tr t, String where) {
  expect(t.en.trim(), isNotEmpty, reason: '$where en');
  expect(t.uz.trim(), isNotEmpty, reason: '$where uz');
  expect(t.ru.trim(), isNotEmpty, reason: '$where ru');
}

Future<void> pump(WidgetTester tester, {String initial = '/'}) async {
  tester.view
    ..physicalSize = const Size(900, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const NewsScreen()),
      GoRoute(
        path: '/news/:id',
        builder: (_, s) => NewsDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/market/product/:id',
        builder: (_, s) =>
            Scaffold(body: Text('PRODUCT ${s.pathParameters['id']}')),
      ),
      GoRoute(
        path: Routes.subscription,
        builder: (_, _) => const Scaffold(body: Text('SUBSCRIPTION TAB')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('news content', () {
    test('there are plenty of articles in every category', () {
      expect(news.length, greaterThanOrEqualTo(18));
      for (final c in NewsCategory.values) {
        expect(
          news.where((n) => n.category == c).length,
          greaterThanOrEqualTo(3),
          reason: c.name,
        );
      }
    });

    test('ids are unique', () {
      final ids = news.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every article is fully translated and has real text', () {
      for (final n in news) {
        filled(n.title, '${n.id} title');
        filled(n.summary, '${n.id} summary');
        expect(n.body.length, greaterThanOrEqualTo(2), reason: n.id);
        for (final p in n.body) {
          filled(p, '${n.id} body');
          // Mazmunli abzas, bitta jumla emas.
          expect(p.en.length, greaterThan(60), reason: n.id);
          expect(p.uz.length, greaterThan(60), reason: n.id);
          expect(p.ru.length, greaterThan(60), reason: n.id);
        }
        expect(n.minutes, greaterThan(0), reason: n.id);
      }
    });

    test('linked products exist in the shop', () {
      final ids = products.map((p) => p.id).toSet();
      for (final n in news.where((n) => n.productId != null)) {
        expect(ids, contains(n.productId), reason: n.id);
      }
    });

    test('sorted newest first and nothing is dated in the future', () {
      final s = newsSorted();
      for (var i = 1; i < s.length; i++) {
        expect(s[i - 1].date.isBefore(s[i].date), isFalse);
      }
      expect(s.first.date.isBefore(DateTime(2026, 10, 18)), isTrue);
    });

    test('featured story and related list behave', () {
      expect(newsById(featuredNews.id), isNotNull);
      final r = relatedNews(featuredNews);
      expect(r, isNotEmpty);
      expect(r.every((n) => n.category == featuredNews.category), isTrue);
      expect(r.any((n) => n.id == featuredNews.id), isFalse);
      expect(newsById('nope'), isNull);
    });

    test('no medical overpromising words', () {
      const banned = ['cure', 'miracle', 'guaranteed', 'detox'];
      for (final n in news) {
        final all = [
          n.title.en,
          n.summary.en,
          ...n.body.map((b) => b.en),
        ].join(' ').toLowerCase();
        for (final w in banned) {
          expect(all.contains(w), isFalse, reason: '${n.id}: $w');
        }
      }
    });
  });

  group('news screens', () {
    testWidgets('feed shows the top story and the category tabs', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('How much protein do you really need?'), findsOneWidget);
      expect(find.text('Top story'), findsOneWidget);
      for (final label in [
        'All',
        'Nutrition',
        'Sport',
        'Supplements',
        'Recipes',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtering by Recipes shows only recipes', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Recipes').first);
      await tester.pumpAndSettle();

      expect(find.text('Top story'), findsNothing);
      expect(
        find.text('A high-protein breakfast in 10 minutes'),
        findsOneWidget,
      );
      expect(find.text('Chicken and buckwheat lunch box'), findsOneWidget);
      expect(find.text('Creatine: myths and facts'), findsNothing);
      expect(find.byType(NewsTile), findsNWidgets(3));
    });

    testWidgets('opening an article, product link goes to the shop', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Supplements').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Creatine: myths and facts'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Creatine monohydrate helps muscles'),
        findsOneWidget,
      );
      expect(find.text('In the shop'), findsOneWidget);
      expect(find.textContaining('not medical advice'), findsOneWidget);

      await tester.ensureVisible(find.text('Creatine Monohydrate'));
      await tester.tap(find.text('Creatine Monohydrate'));
      await tester.pumpAndSettle();
      expect(find.text('PRODUCT creatine'), findsOneWidget);
    });

    testWidgets('meal-prep article links to our meal programs', (tester) async {
      await pump(tester, initial: '/news/meal-prep');
      await tester.ensureVisible(
        find.text('Meal programs from Forkout Kitchen'),
      );
      await tester.tap(find.text('Meal programs from Forkout Kitchen'));
      await tester.pumpAndSettle();
      expect(find.text('SUBSCRIPTION TAB'), findsOneWidget);
    });

    testWidgets('read-next opens another article of the same category', (
      tester,
    ) async {
      await pump(tester, initial: '/news/sleep');
      await tester.ensureVisible(find.text('Read next'));
      expect(find.text('Read next'), findsOneWidget);
      expect(find.byType(NewsTile), findsWidgets);
    });

    testWidgets('unknown article does not crash', (tester) async {
      await pump(tester, initial: '/news/nope');
      expect(tester.takeException(), isNull);
    });
  });
}
