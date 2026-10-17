import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_l10n.dart';
import '../../../core/storage/stored_list.dart';
import 'market_models.dart';

/// Kuryer kuniga uch mahal yetkazadi.
enum MealSlot { breakfast, lunch, dinner }

extension MealSlotInfo on MealSlot {
  Tr get label => switch (this) {
    MealSlot.breakfast => const Tr('Breakfast', 'Nonushta', 'Завтрак'),
    MealSlot.lunch => const Tr('Lunch', 'Tushlik', 'Обед'),
    MealSlot.dinner => const Tr('Dinner', 'Kechki ovqat', 'Ужин'),
  };

  /// Yetkazish oynasi.
  String get window => switch (this) {
    MealSlot.breakfast => '07:00–09:00',
    MealSlot.lunch => '12:00–14:00',
    MealSlot.dinner => '18:00–20:00',
  };

  IconData get icon => switch (this) {
    MealSlot.breakfast => Icons.wb_twilight_rounded,
    MealSlot.lunch => Icons.wb_sunny_rounded,
    MealSlot.dinner => Icons.nights_stay_rounded,
  };
}

/// 3 oylik obunaga chegirma.
const threeMonthDiscount = 0.10;

/// Obuna narxi: ratsionning kunlik narxi × tanlangan mahallar ulushi × kunlar,
/// 3 oyda chegirma bilan. 1000 so'mga yaxlitlanadi.
({int perDay, int days, int subtotal, int discount, int total})
subscriptionPrice(
  MealPlanOffer plan, {
  required int months,
  required int slots,
}) {
  final perDay = ((plan.pricePerDay * slots / 3) / 1000).round() * 1000;
  final days = months * 30;
  final subtotal = perDay * days;
  final discount = months >= 3
      ? ((subtotal * threeMonthDiscount) / 1000).round() * 1000
      : 0;
  return (
    perDay: perDay,
    days: days,
    subtotal: subtotal,
    discount: discount,
    total: subtotal - discount,
  );
}

/// To'lashga tayyorlangan, hali yaratilmagan obuna (formadan to'lov ekraniga).
class SubscriptionDraft {
  const SubscriptionDraft({
    required this.planId,
    required this.months,
    required this.slots,
    required this.startDate,
    required this.address,
    required this.phone,
  });

  final String planId;
  final int months;
  final Set<MealSlot> slots;
  final DateTime startDate;
  final String address;
  final String phone;

  MealPlanOffer get plan => mealPlanById(planId)!;
  int get total =>
      subscriptionPrice(plan, months: months, slots: slots.length).total;
}

enum SubscriptionStatus { upcoming, active, paused, ended, canceled }

class Subscription {
  const Subscription({
    required this.id,
    required this.createdAt,
    required this.planId,
    required this.months,
    required this.slots,
    required this.startDate,
    required this.address,
    required this.phone,
    required this.total,
    required this.payment,
    this.pauseFrom,
    this.pauseUntil,
    this.pausedDays = 0,
    this.canceledAt,
  });

  final String id;
  final DateTime createdAt;
  final String planId;
  final int months;
  final Set<MealSlot> slots;
  final DateTime startDate;
  final String address;
  final String phone;
  final int total;
  final PaymentMethod payment;

  /// Pauza: [pauseFrom, pauseUntil) kunlarida yetkazilmaydi.
  final DateTime? pauseFrom;
  final DateTime? pauseUntil;

  /// Pauza kunlari obuna oxiriga qo'shiladi — foydalanuvchi to'langan kunlarni yo'qotmaydi.
  final int pausedDays;
  final DateTime? canceledAt;

  /// Obuna tugash sanasi (pauza kunlari bilan).
  DateTime get endDate =>
      startDate.add(Duration(days: months * 30 + pausedDays));

  SubscriptionStatus statusAt(DateTime now) {
    final today = DateUtils.dateOnly(now);
    if (canceledAt != null) return SubscriptionStatus.canceled;
    if (!today.isBefore(endDate)) return SubscriptionStatus.ended;
    final from = pauseFrom;
    final until = pauseUntil;
    if (from != null &&
        until != null &&
        !today.isBefore(from) &&
        today.isBefore(until)) {
      return SubscriptionStatus.paused;
    }
    if (today.isBefore(startDate)) return SubscriptionStatus.upcoming;
    return SubscriptionStatus.active;
  }

  SubscriptionStatus get status => statusAt(DateTime.now());

  /// Bekor qilinmagan va tugamagan.
  bool get isLive =>
      status != SubscriptionStatus.canceled &&
      status != SubscriptionStatus.ended;
  bool get isActive => isLive;

  /// Hozir yoki kelajakda pauza belgilanganmi (yangisini qo'yib bo'lmaydi).
  bool hasPause(DateTime now) =>
      pauseUntil != null && DateUtils.dateOnly(now).isBefore(pauseUntil!);

  /// Kuryer ertaga yetkazadimi (kun oldin tayyorlanadi, shuning uchun pauza ertadan boshlanadi).
  DateTime _tomorrow(DateTime now) =>
      DateUtils.dateOnly(now).add(const Duration(days: 1));

  /// [days] kunga pauza: ertadan (yoki obuna boshlangandan) boshlab.
  Subscription paused(int days, DateTime now) {
    assert(isLive && !hasPause(now) && days > 0);
    final t = _tomorrow(now);
    final from = t.isAfter(startDate) ? t : startDate;
    return _copy(
      pauseFrom: from,
      pauseUntil: from.add(Duration(days: days)),
      pausedDays: pausedDays + days,
    );
  }

  /// Pauzani to'xtatish: ertadan yetkazish qayta boshlanadi, ishlatilmagan pauza
  /// kunlari obuna oxiridan ayriladi.
  Subscription resumed(DateTime now) {
    final from = pauseFrom;
    final until = pauseUntil;
    if (from == null || until == null || !hasPause(now)) return this;
    final t = _tomorrow(now);
    final newUntil = t.isAfter(from) ? t : from;
    final returned = until.difference(newUntil).inDays;
    return _copy(
      pauseFrom: newUntil == from ? null : from,
      pauseUntil: newUntil == from ? null : newUntil,
      pausedDays: pausedDays - returned,
      clearPause: newUntil == from,
    );
  }

  Subscription canceled(DateTime now) => _copy(canceledAt: now);

  Subscription withDelivery({String? address, String? phone}) =>
      _copy(address: address, phone: phone);

  Subscription _copy({
    String? address,
    String? phone,
    DateTime? pauseFrom,
    DateTime? pauseUntil,
    int? pausedDays,
    DateTime? canceledAt,
    bool clearPause = false,
  }) => Subscription(
    id: id,
    createdAt: createdAt,
    planId: planId,
    months: months,
    slots: slots,
    startDate: startDate,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    total: total,
    payment: payment,
    pauseFrom: clearPause ? null : (pauseFrom ?? this.pauseFrom),
    pauseUntil: clearPause ? null : (pauseUntil ?? this.pauseUntil),
    pausedDays: pausedDays ?? this.pausedDays,
    canceledAt: canceledAt ?? this.canceledAt,
  );

  MealPlanOffer? get plan => mealPlanById(planId);

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'planId': planId,
    'months': months,
    'slots': [for (final s in slots) s.name],
    'startDate': startDate.toIso8601String(),
    'address': address,
    'phone': phone,
    'total': total,
    'payment': payment.name,
    'pauseFrom': pauseFrom?.toIso8601String(),
    'pauseUntil': pauseUntil?.toIso8601String(),
    'pausedDays': pausedDays,
    'canceledAt': canceledAt?.toIso8601String(),
  };

  static Subscription fromJson(Map<String, Object?> j) {
    DateTime? date(String key) =>
        j[key] == null ? null : DateTime.parse(j[key]! as String);
    return Subscription(
      id: j['id'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      planId: j['planId'] as String,
      months: (j['months'] as num).toInt(),
      slots: {
        for (final n in (j['slots'] as List? ?? const []))
          ...MealSlot.values.where((s) => s.name == n),
      },
      startDate: DateTime.parse(j['startDate'] as String),
      address: j['address'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      total: (j['total'] as num).toInt(),
      payment: PaymentMethod.values.firstWhere(
        (p) => p.name == j['payment'],
        orElse: () => PaymentMethod.cash,
      ),
      pauseFrom: date('pauseFrom'),
      pauseUntil: date('pauseUntil'),
      pausedDays: (j['pausedDays'] as num?)?.toInt() ?? 0,
      canceledAt: date('canceledAt'),
    );
  }
}

/// Obunalar (demo — to'lov o'tkazilmaydi, serverga yuborilmaydi).
/// TODO(backend): obunalar serverda, to'lov — Payme/Click, kuryer jadvali admin paneldan.
final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>(
      (ref) => SubscriptionsNotifier(ref),
    );

class SubscriptionsNotifier extends StoredList<Subscription> {
  SubscriptionsNotifier(Ref ref) : super(ref, 'subscriptions');

  @override
  Subscription decode(Map<String, Object?> json) => Subscription.fromJson(json);
  @override
  Map<String, Object?> encode(Subscription item) => item.toJson();

  void add(Subscription s) => save([s, ...state]);

  /// Obunani almashtiradi (pauza, bekor qilish, manzil o'zgartirish).
  void replace(Subscription s) =>
      save([for (final e in state) e.id == s.id ? s : e]);
}
