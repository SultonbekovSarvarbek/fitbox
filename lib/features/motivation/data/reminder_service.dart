import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../l10n/app_localizations.dart';
import 'discipline.dart';

/// Mahalliy eslatmalar (server kerak emas):
/// - jadvaldagi kunlarda belgilangan vaqtda "Mashg'ulot vaqti!";
/// - mashg'ulot kunlari kechqurun "Seriyang yonib ketmoqda" — agar bugun hali qilinmagan bo'lsa.
class ReminderService {
  ReminderService._();

  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _init;

  static const _days = 28; // necha kun oldinga rejalashtiriladi
  /// Har kun uchun o'z id'si (sana bo'yicha) — kunlar siljiganda ham
  /// kechagi ko'rsatilgan bildirishnoma bilan to'qnashmaydi.
  static int _idFor(DateTime day, {required bool saver}) {
    final n = DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime.utc(2024)).inDays;
    return 10000 + (n % 5000) * 2 + (saver ? 1 : 0);
  }

  Future<void> _ensureInit() => _init ??= () async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }();

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Bildirishnomaga ruxsat so'rash (Android 13+, iOS). Ruxsat berilsa `true`.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await _ensureInit();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'training_reminders',
      'Training reminders',
      channelDescription: 'Workout schedule and streak reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Kechki "seriyani saqla" vaqti: eslatmadan 2 soat keyin, lekin 20:00 dan erta emas.
  static int saverHour(TrainingSchedule s) => (s.hour + 2).clamp(20, 23);

  Future<void> _queue = Future.value();

  /// Navbat bilan: ketma-ket chaqiruvlar bir-biriga aralashmaydi.
  Future<void> reschedule({
    required TrainingSchedule schedule,
    required bool doneToday,
    required int streak,
    required Locale locale,
  }) => _queue = _queue.then(
    (_) => _reschedule(
      schedule: schedule,
      doneToday: doneToday,
      streak: streak,
      locale: locale,
    ),
  );

  Future<void> _reschedule({
    required TrainingSchedule schedule,
    required bool doneToday,
    required int streak,
    required Locale locale,
  }) async {
    if (!_supported) return;
    try {
      await _ensureInit();
      // Faqat hali kelmagan eslatmalarni bekor qilamiz — ekranda turganlari qoladi.
      for (final p in await _plugin.pendingNotificationRequests()) {
        await _plugin.cancel(id: p.id);
      }
      if (!schedule.enabled) return;
      final l10n = lookupAppLocalizations(locale);
      final now = tz.TZDateTime.now(tz.local);

      // Bir martalik eslatmalar, keyingi [_days] kun uchun. Ilova har ochilganda
      // (va mashg'ulot yozilganda) qayta rejalashtiriladi — shuning uchun bugun
      // mashg'ulot qilingan bo'lsa, bugungi eslatmalar aniq bekor bo'ladi.
      // (Haftalik takrorlash rejimi bugungi kunni o'tkazib yuborishga imkon bermaydi.)
      for (var i = 0; i < _days; i++) {
        final day = now.add(Duration(days: i));
        if (!schedule.isTrainingDay(day)) continue;
        if (i == 0 && doneToday) continue;

        final remindAt = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          schedule.hour,
          schedule.minute,
        );
        if (remindAt.isAfter(now)) {
          await _plugin.zonedSchedule(
            id: _idFor(day, saver: false),
            scheduledDate: remindAt,
            notificationDetails: _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            title: l10n.reminderTitle,
            body: l10n.reminderBody,
          );
        }

        // "Seriyani saqla" — kechqurun, agar shu kuni hali mashg'ulot bo'lmasa.
        final saverAt = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          saverHour(schedule),
        );
        if (saverAt.isAfter(now) && saverAt.isAfter(remindAt)) {
          await _plugin.zonedSchedule(
            id: _idFor(day, saver: true),
            scheduledDate: saverAt,
            notificationDetails: _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            title: l10n.streakSaverTitle,
            body: i == 0 && streak > 0
                ? l10n.streakSaverBody(streak)
                : l10n.streakSaverBodyNoStreak,
          );
        }
      }
    } catch (e) {
      debugPrint('ReminderService: $e');
    }
  }
}
