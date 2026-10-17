import 'package:fitness_app/core/content/content_l10n.dart';
import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/product_info.dart';
import 'package:fitness_app/features/market/product_screen.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void expectFilled(Tr t, String where) {
  expect(t.en.trim(), isNotEmpty, reason: '$where: en');
  expect(t.uz.trim(), isNotEmpty, reason: '$where: uz');
  expect(t.ru.trim(), isNotEmpty, reason: '$where: ru');
}

Future<ProviderContainer> pump(WidgetTester tester, String id) async {
  tester.view
    ..physicalSize = const Size(900, 3200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductScreen(id: id),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('product info content', () {
    test('every product has a full description', () {
      for (final p in products) {
        final info = productInfo[p.id];
        expect(info, isNotNull, reason: '${p.id} has no info');
        expect(info!.benefits, isNotEmpty, reason: '${p.id} benefits');
        expect(info.howToUse, isNotEmpty, reason: '${p.id} howToUse');
        expect(info.facts, isNotEmpty, reason: '${p.id} facts');
        expect(
          info.contraindications,
          isNotEmpty,
          reason: '${p.id} contraindications',
        );
      }
    });

    test('every text is translated into all three languages', () {
      for (final e in productInfo.entries) {
        final i = e.value;
        for (final t in [
          ...i.benefits,
          ...i.howToUse,
          ...i.contraindications,
          for (final f in i.facts) ...[f.$1, f.$2],
          ?i.storage,
        ]) {
          expectFilled(t, e.key);
        }
      }
      expectFilled(supplementDisclaimer, 'disclaimer');
    });

    test('no info for unknown products', () {
      final ids = products.map((p) => p.id).toSet();
      expect(productInfo.keys.toSet().difference(ids), isEmpty);
    });
  });

  group('product page', () {
    testWidgets('shows what it is for, usage, composition and warnings', (
      tester,
    ) async {
      await pump(tester, 'creatine');
      expect(find.text('Creatine Monohydrate'), findsOneWidget);
      expect(find.text("What it's for"), findsOneWidget);
      expect(find.text('How to use'), findsOneWidget);
      expect(find.text('Composition'), findsOneWidget);
      expect(find.text('Contraindications'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.textContaining('5 g (1 level scoop)'), findsOneWidget);
      expect(find.textContaining('Kidney disease'), findsOneWidget);
      expect(find.textContaining('not a medicine'), findsOneWidget);
    });

    testWidgets('add to cart, change quantity', (tester) async {
      final c = await pump(tester, 'whey-isolate');
      expect(c.read(cartProvider), isEmpty);

      await tester.tap(find.text('Add to cart'));
      await tester.pump();
      expect(c.read(cartProvider)['whey-isolate'], 1);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(c.read(cartProvider)['whey-isolate'], 2);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(c.read(cartProvider), isEmpty);
      expect(find.text('Add to cart'), findsOneWidget);
    });

    testWidgets('unknown id does not crash', (tester) async {
      await pump(tester, 'nope');
      expect(find.text('Product not found'), findsOneWidget);
    });
  });
}
