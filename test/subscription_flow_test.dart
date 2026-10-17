import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/subscription_models.dart';
import 'package:fitness_app/features/market/subscription_payment_screen.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SubscriptionDraft draft() => SubscriptionDraft(
  planId: 'balance-1600',
  months: 3,
  slots: {MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner},
  startDate: DateTime.now().add(const Duration(days: 1)),
  address: 'Chilonzor 5, 12',
  phone: '+998901234567',
);

Future<ProviderContainer> pumpPayment(WidgetTester tester) async {
  // Uzun ekran: pastdagi "To'lash" tugmasi ham yasalsin (ro'yxat dangasa).
  tester.view
    ..physicalSize = const Size(900, 2600)
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
        home: SubscriptionPaymentScreen(draft: draft()),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('payme: choose -> processing -> subscription is created', (
    tester,
  ) async {
    final c = await pumpPayment(tester);
    expect(c.read(subscriptionsProvider), isEmpty);

    // Default method is Payme; the button shows the amount.
    await tester.tap(find.textContaining('Pay ·'));
    await tester.pump();
    expect(find.textContaining('Waiting for Payme'), findsOneWidget);
    // Nothing is saved before the provider "answers".
    expect(c.read(subscriptionsProvider), isEmpty);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));

    final subs = c.read(subscriptionsProvider);
    expect(subs, hasLength(1));
    expect(subs.single.payment, PaymentMethod.payme);
    expect(subs.single.months, 3);
    expect(subs.single.total, draft().total);
    expect(find.text('Subscription is active'), findsOneWidget);
    expect(find.text('My subscription'), findsOneWidget);
  });

  testWidgets('cash on delivery: no redirect, pay the courier note', (
    tester,
  ) async {
    final c = await pumpPayment(tester);
    await tester.tap(find.text('Cash'));
    await tester.pump();
    await tester.tap(find.text('Confirm subscription'));
    await tester.pump();
    expect(find.text('Creating subscription…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));

    expect(c.read(subscriptionsProvider).single.payment, PaymentMethod.cash);
    expect(find.text('Pay the courier on the first delivery.'), findsOneWidget);
  });
}
