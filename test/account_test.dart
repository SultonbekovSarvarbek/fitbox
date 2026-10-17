import 'package:fitness_app/features/auth/phone.dart';
import 'package:fitness_app/features/auth/session.dart';
import 'package:fitness_app/features/market/data/market_models.dart';
import 'package:fitness_app/features/market/data/subscription_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final today = DateTime(2026, 10, 17, 14, 30);

Subscription sub({DateTime? start, int months = 1}) => Subscription(
  id: 'SUB-1',
  createdAt: today,
  planId: 'balance-1600',
  months: months,
  slots: {MealSlot.breakfast, MealSlot.lunch, MealSlot.dinner},
  startDate: start ?? DateTime(2026, 10, 10),
  address: 'Chilonzor 5',
  phone: '+998901234567',
  total: 3150000,
  payment: PaymentMethod.payme,
);

void main() {
  group('phone', () {
    test('normalizes national and international forms', () {
      expect(normalizePhone('90 123 45 67'), '+998901234567');
      expect(normalizePhone('+998 90 123-45-67'), '+998901234567');
      expect(normalizePhone('998901234567'), '+998901234567');
    });

    test('rejects wrong lengths', () {
      expect(normalizePhone('90123'), isNull);
      expect(normalizePhone('9012345678'), isNull);
      expect(normalizePhone(''), isNull);
    });

    test('formats for display', () {
      expect(formatPhone('+998901234567'), '+998 90 123 45 67');
    });
  });

  group('subscription pause / resume / cancel', () {
    test('running subscription is active, then pause starts tomorrow', () {
      final s = sub();
      expect(s.statusAt(today), SubscriptionStatus.active);

      final p = s.paused(7, today);
      expect(p.pauseFrom, DateTime(2026, 10, 18));
      expect(p.pauseUntil, DateTime(2026, 10, 25));
      // Today's delivery is still on; the pause starts tomorrow.
      expect(p.statusAt(today), SubscriptionStatus.active);
      expect(p.statusAt(DateTime(2026, 10, 20)), SubscriptionStatus.paused);
      expect(p.statusAt(DateTime(2026, 10, 25)), SubscriptionStatus.active);
    });

    test('pause days are added to the end date', () {
      final s = sub();
      final p = s.paused(7, today);
      expect(p.endDate, s.endDate.add(const Duration(days: 7)));
    });

    test('resume during a pause gives unused days back', () {
      final s = sub().paused(7, today); // 18..25 Oct
      final mid = DateTime(2026, 10, 20, 9);
      final r = s.resumed(mid); // delivery returns on 21 Oct
      expect(r.pauseUntil, DateTime(2026, 10, 21));
      // Used 18, 19, 20 -> 3 days; 4 are returned.
      expect(r.pausedDays, 3);
      expect(r.statusAt(mid), SubscriptionStatus.paused);
      expect(r.statusAt(DateTime(2026, 10, 21)), SubscriptionStatus.active);
    });

    test('resume before the pause starts removes it completely', () {
      final s = sub().paused(7, today);
      final r = s.resumed(today); // pause would start tomorrow
      expect(r.pauseFrom, isNull);
      expect(r.pauseUntil, isNull);
      expect(r.pausedDays, 0);
      expect(r.endDate, sub().endDate);
    });

    test('only one pause at a time', () {
      final p = sub().paused(3, today);
      expect(p.hasPause(today), isTrue);
      expect(sub().hasPause(today), isFalse);
    });

    test('a future subscription pauses from its start date', () {
      final s = sub(start: DateTime(2026, 11, 1));
      expect(s.statusAt(today), SubscriptionStatus.upcoming);
      final p = s.paused(3, today);
      expect(p.pauseFrom, DateTime(2026, 11, 1));
    });

    test('cancel wins over everything and is not live', () {
      final c = sub().paused(7, today).canceled(today);
      expect(c.statusAt(DateTime(2026, 10, 20)), SubscriptionStatus.canceled);
      expect(c.isLive, isFalse);
    });

    test('ends after months plus paused days', () {
      final s = sub(start: DateTime(2026, 9, 1)); // ends 1 Oct
      expect(s.statusAt(today), SubscriptionStatus.ended);
      expect(s.isLive, isFalse);
    });

    test('state survives json', () {
      final s = sub().paused(7, today);
      final back = Subscription.fromJson(s.toJson());
      expect(back.pauseFrom, s.pauseFrom);
      expect(back.pauseUntil, s.pauseUntil);
      expect(back.pausedDays, 7);
      expect(back.canceledAt, isNull);

      final c = Subscription.fromJson(s.canceled(today).toJson());
      expect(c.canceledAt, today);
    });

    test('delivery details can change', () {
      final s = sub().withDelivery(address: 'Yunusobod 7');
      expect(s.address, 'Yunusobod 7');
      expect(s.phone, '+998901234567');
    });
  });

  group('session', () {
    late SharedPreferences prefs;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('register -> start -> signIn -> signOut keeps the account', () async {
      const phone = '+998901234567';
      expect(Session.isRegistered(prefs, phone), isFalse);

      await Session.register(prefs, phone);
      await Session.start(prefs, phone);
      // Anketa tugamaguncha hali "kirgan" emas.
      expect(Session.isSignedIn(prefs), isFalse);
      expect(Session.phone(prefs), phone);

      await Session.signIn(prefs);
      expect(Session.isSignedIn(prefs), isTrue);

      await Session.signOut(prefs);
      expect(Session.isSignedIn(prefs), isFalse);
      expect(Session.phone(prefs), isNull);
      expect(Session.isRegistered(prefs, phone), isTrue);
    });

    test('delete wipes data but keeps language and other accounts', () async {
      await Session.register(prefs, '+998901111111');
      await Session.register(prefs, '+998902222222');
      await Session.start(prefs, '+998901111111');
      await Session.signIn(prefs);
      await prefs.setString('locale', 'ru');
      await prefs.setString('user_profile', '{"weightKg":80}');
      await prefs.setString('orders', '[]');

      await Session.deleteAccount(prefs, phone: '+998901111111');

      expect(Session.isSignedIn(prefs), isFalse);
      expect(Session.phone(prefs), isNull);
      expect(prefs.getString('user_profile'), isNull);
      expect(prefs.getString('orders'), isNull);
      expect(Session.isRegistered(prefs, '+998901111111'), isFalse);
      expect(Session.isRegistered(prefs, '+998902222222'), isTrue);
      expect(prefs.getString('locale'), 'ru');
    });
  });
}
