import 'dart:convert';

import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/subscription_models.dart';
import 'package:fitness_app/features/market/subscription_detail_screen.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pump(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(900, 2600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final sub = Subscription(
    id: 'SUB-1',
    createdAt: DateTime.now(),
    planId: 'balance-1600',
    months: 1,
    slots: {MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner},
    startDate: DateUtils.dateOnly(
      DateTime.now(),
    ).subtract(const Duration(days: 5)),
    address: 'Chilonzor 5',
    phone: '+998901234567',
    total: 3150000,
    payment: PaymentMethod.payme,
  );
  SharedPreferences.setMockInitialValues({
    'subscriptions': jsonEncode([sub.toJson()]),
  });
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
        home: const SubscriptionDetailScreen(id: 'SUB-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Subscription current(ProviderContainer c) =>
    c.read(subscriptionsProvider).single;

void main() {
  testWidgets('pause for 7 days, then resume', (tester) async {
    final c = await pump(tester);
    expect(find.text('Active'), findsOneWidget);
    final endBefore = current(c).endDate;

    await tester.tap(find.text('Pause meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 days'));
    await tester.pumpAndSettle();

    final paused = current(c);
    expect(paused.pausedDays, 7);
    expect(paused.hasPause(DateTime.now()), isTrue);
    expect(paused.endDate, endBefore.add(const Duration(days: 7)));
    // Pauza ertadan boshlanadi, bugun hali "Faol".
    expect(find.text('Resume meals'), findsOneWidget);
    expect(find.text('Pause meals'), findsNothing);

    await tester.tap(find.text('Resume meals'));
    await tester.pumpAndSettle();
    final resumed = current(c);
    expect(resumed.pausedDays, 0);
    expect(resumed.pauseUntil, isNull);
    expect(resumed.endDate, endBefore);
    expect(find.text('Pause meals'), findsOneWidget);
  });

  testWidgets('cancel asks first; keeping it changes nothing', (tester) async {
    final c = await pump(tester);

    await tester.tap(find.text('Cancel subscription'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel subscription?'), findsOneWidget);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(current(c).canceledAt, isNull);

    await tester.tap(find.text('Cancel subscription'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel subscription'),
      ),
    );
    await tester.pumpAndSettle();

    expect(current(c).canceledAt, isNotNull);
    expect(find.text('Canceled'), findsOneWidget);
    // Bekor qilingan obunada boshqaruv tugmalari yo'q, "qayta" tugmasi bor.
    expect(find.text('Pause meals'), findsNothing);
    expect(find.text('Subscribe again'), findsOneWidget);
  });

  testWidgets('change the delivery address', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Change address'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Yunusobod 7, 14');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(current(c).address, 'Yunusobod 7, 14');
    expect(find.text('Yunusobod 7, 14'), findsOneWidget);
  });

  testWidgets('address too short is rejected', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Change address'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'ab');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(current(c).address, 'Chilonzor 5');
  });
}
