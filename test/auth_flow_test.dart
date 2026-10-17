import 'package:fitness_app/app/router.dart';
import 'package:fitness_app/core/app_reset.dart';
import 'package:fitness_app/core/locale/locale_provider.dart';
import 'package:fitness_app/features/auth/login_screen.dart';
import 'package:fitness_app/features/auth/otp_screen.dart';
import 'package:fitness_app/features/auth/session.dart';
import 'package:fitness_app/features/auth/signup_screen.dart';
import 'package:fitness_app/features/profile/delete_account_sheet.dart';
import 'package:fitness_app/features/setup/setup_profile.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Harness {
  Harness(this.prefs, this.container);

  final SharedPreferences prefs;
  final ProviderContainer container;
}

/// Kichik router: haqiqiy ekranlar, Setup/Home o'rniga belgilar.
Future<Harness> pump(
  WidgetTester tester, {
  required String initial,
  Map<String, Object> prefsValues = const {},
}) async {
  tester.view
    ..physicalSize = const Size(900, 2200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignupScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (_, s) => OtpScreen(args: s.extra! as OtpArgs),
      ),
      GoRoute(
        path: Routes.setup,
        builder: (_, _) => const Scaffold(body: Text('SETUP SCREEN')),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const Scaffold(body: Text('HOME SCREEN')),
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
  return Harness(prefs, container);
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('signup: details -> code -> account is created, goes to survey', (
    tester,
  ) async {
    final h = await pump(tester, initial: Routes.signup);

    // Rozilik belgisisiz davom etib bo'lmaydi.
    await tester.enterText(find.byType(TextFormField).at(0), 'Aziz Karimov');
    await tester.enterText(find.byType(TextFormField).at(1), '901234567');
    await tester.tap(find.text('Get code'));
    await settle(tester);
    expect(find.text('SMS CODE'), findsNothing);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Get code'));
    await settle(tester);
    expect(find.text('SMS CODE'), findsOneWidget);
    expect(find.textContaining('+998 90 123 45 67'), findsOneWidget);

    // Noto'g'ri kod.
    await tester.enterText(find.byType(TextField), '111111');
    await settle(tester);
    expect(find.text('Wrong code. Try again.'), findsOneWidget);
    expect(Session.isRegistered(h.prefs, '+998901234567'), isFalse);

    // To'g'ri kod.
    await tester.enterText(find.byType(TextField), '123456');
    await settle(tester);
    expect(find.text('SETUP SCREEN'), findsOneWidget);
    expect(Session.isRegistered(h.prefs, '+998901234567'), isTrue);
    expect(Session.phone(h.prefs), '+998901234567');
    // Anketa tugamaguncha hali "kirgan" emas.
    expect(Session.isSignedIn(h.prefs), isFalse);
    final user = h.container.read(userProvider);
    expect(user.fullName, 'Aziz Karimov');
    expect(user.phone, '+998901234567');
  });

  testWidgets('login with an unknown number offers to sign up', (tester) async {
    await pump(tester, initial: Routes.login);
    await tester.enterText(find.byType(TextFormField), '909999999');
    await tester.tap(find.text('Get code'));
    await settle(tester);
    expect(find.text('No account with this number yet.'), findsOneWidget);
    expect(find.text('SMS CODE'), findsNothing);
  });

  testWidgets('login validates the phone length', (tester) async {
    await pump(tester, initial: Routes.login);
    await tester.enterText(find.byType(TextFormField), '9012');
    await tester.tap(find.text('Get code'));
    await tester.pump();
    expect(find.text('Enter 9 digits of your number'), findsOneWidget);
  });

  testWidgets('login of a finished account goes straight home', (tester) async {
    final h = await pump(
      tester,
      initial: Routes.login,
      prefsValues: {
        'accounts': ['+998901234567'],
        'setup_done': ['+998901234567'],
      },
    );
    await tester.enterText(find.byType(TextFormField), '90 123 45 67');
    await tester.tap(find.text('Get code'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await settle(tester);
    expect(find.text('HOME SCREEN'), findsOneWidget);
    expect(Session.isSignedIn(h.prefs), isTrue);
  });

  testWidgets('login of an account without a survey continues the survey', (
    tester,
  ) async {
    await pump(
      tester,
      initial: Routes.login,
      prefsValues: {
        'accounts': ['+998901234567'],
      },
    );
    await tester.enterText(find.byType(TextFormField), '901234567');
    await tester.tap(find.text('Get code'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await settle(tester);
    expect(find.text('SETUP SCREEN'), findsOneWidget);
  });

  testWidgets('signup with a registered number says so', (tester) async {
    await pump(
      tester,
      initial: Routes.signup,
      prefsValues: {
        'accounts': ['+998901234567'],
      },
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Aziz');
    await tester.enterText(find.byType(TextFormField).at(1), '901234567');
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Get code'));
    await settle(tester);
    expect(find.text('This number is already registered.'), findsOneWidget);
  });

  testWidgets('delete account: needs the checkbox, then wipes everything', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'accounts': ['+998901234567', '+998907777777'],
      'setup_done': ['+998901234567'],
      'session_phone': '+998901234567',
      'signed_in': true,
      'locale': 'en',
      'orders': '[{"x":1}]',
      'user_profile': '{"weightKg":99}',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    tester.view
      ..physicalSize = const Size(900, 2200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => showDeleteAccountSheet(context, ref),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    final epoch = appResetEpoch.value;

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account?'), findsOneWidget);

    // Belgi qo'yilmaguncha tugma ishlamaydi.
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account?'), findsOneWidget);
    expect(Session.isSignedIn(prefs), isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(Session.isSignedIn(prefs), isFalse);
    expect(Session.phone(prefs), isNull);
    expect(prefs.getString('orders'), isNull);
    expect(prefs.getString('user_profile'), isNull);
    expect(Session.isRegistered(prefs, '+998901234567'), isFalse);
    expect(Session.isRegistered(prefs, '+998907777777'), isTrue);
    expect(prefs.getString('locale'), 'en');
    expect(appResetEpoch.value, epoch + 1);
  });

  testWidgets('delete account: cancel leaves everything in place', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'accounts': ['+998901234567'],
      'session_phone': '+998901234567',
      'signed_in': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    tester.view
      ..physicalSize = const Size(900, 2200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => showDeleteAccountSheet(context, ref),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    final epoch = appResetEpoch.value;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(Session.isSignedIn(prefs), isTrue);
    expect(Session.isRegistered(prefs, '+998901234567'), isTrue);
    expect(appResetEpoch.value, epoch);
  });
}
