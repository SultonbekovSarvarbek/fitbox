import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../../../core/locale/locale_provider.dart';
import '../../progress/data/progress_models.dart';

/// Soat / Samsung Health / Apple Health ma'lumotlari — Health Connect (Android)
/// yoki HealthKit (iOS) orqali. Faqat O'QISH: ilova soat ma'lumotiga hech narsa yozmaydi.
///
/// Zanjir (Samsung): Galaxy Watch → Galaxy Wearable → Samsung Health → Health Connect → ilova.

enum HealthAvailability { checking, available, needsInstall, unsupported }

class WatchData {
  const WatchData({
    this.availability = HealthAvailability.checking,
    this.connected = false,
    this.syncing = false,
    this.lastSync,
    this.steps,
    this.heartRate,
    this.restingHeartRate,
    this.sleepMinutes,
    this.activeKcal,
    this.weightKg,
    this.error,
  });

  final HealthAvailability availability;
  final bool connected;
  final bool syncing;
  final DateTime? lastSync;

  /// Bugungi qadamlar.
  final int? steps;

  /// So'nggi puls (zarba/daqiqa).
  final int? heartRate;
  final int? restingHeartRate;

  /// O'tgan tundagi uyqu (daqiqa).
  final int? sleepMinutes;

  /// Bugun soat yozgan faol kaloriya.
  final int? activeKcal;

  /// So'nggi vazn (tarozi / Samsung Health).
  final double? weightKg;

  final String? error;

  bool get hasAnyData => [
    steps,
    heartRate,
    restingHeartRate,
    sleepMinutes,
    activeKcal,
    weightKg,
  ].any((v) => v != null);

  WatchData copyWith({
    HealthAvailability? availability,
    bool? connected,
    bool? syncing,
    DateTime? lastSync,
    int? steps,
    int? heartRate,
    int? restingHeartRate,
    int? sleepMinutes,
    int? activeKcal,
    double? weightKg,
    String? error,
    bool clearError = false,
  }) => WatchData(
    availability: availability ?? this.availability,
    connected: connected ?? this.connected,
    syncing: syncing ?? this.syncing,
    lastSync: lastSync ?? this.lastSync,
    steps: steps ?? this.steps,
    heartRate: heartRate ?? this.heartRate,
    restingHeartRate: restingHeartRate ?? this.restingHeartRate,
    sleepMinutes: sleepMinutes ?? this.sleepMinutes,
    activeKcal: activeKcal ?? this.activeKcal,
    weightKg: weightKg ?? this.weightKg,
    error: clearError ? null : (error ?? this.error),
  );
}

final healthSyncProvider = StateNotifierProvider<HealthSyncNotifier, WatchData>(
  (ref) => HealthSyncNotifier(ref),
);

class HealthSyncNotifier extends StateNotifier<WatchData> {
  HealthSyncNotifier(this._ref)
    : super(
        WatchData(
          connected: _ref.read(sharedPrefsProvider).getBool(_key) ?? false,
        ),
      ) {
    _init();
  }

  static const _key = 'health_connected';
  final Ref _ref;
  final _health = Health();

  static List<HealthDataType> get _types => [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
    Platform.isIOS ? HealthDataType.SLEEP_ASLEEP : HealthDataType.SLEEP_SESSION,
  ];

  Future<void> _init() async {
    await _health.configure();
    await checkAvailability();
    if (state.connected && state.availability == HealthAvailability.available) {
      await refresh();
    }
  }

  Future<void> checkAvailability() async {
    if (Platform.isIOS) {
      state = state.copyWith(availability: HealthAvailability.available);
      return;
    }
    if (!Platform.isAndroid) {
      state = state.copyWith(availability: HealthAvailability.unsupported);
      return;
    }
    final status = await _health.getHealthConnectSdkStatus();
    state = state.copyWith(
      availability: switch (status) {
        HealthConnectSdkStatus.sdkAvailable => HealthAvailability.available,
        HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
          HealthAvailability.needsInstall,
        _ => HealthAvailability.unsupported,
      },
    );
  }

  /// Play Market'da Health Connect sahifasini ochadi (eski Android'lar uchun).
  Future<void> install() => _health.installHealthConnect();

  /// Ruxsat so'raydi va birinchi sinxronlashni qiladi. Ruxsat berilsa — `true`.
  Future<bool> connect() async {
    try {
      final types = _types;
      final ok = await _health.requestAuthorization(
        types,
        permissions: [for (final _ in types) HealthDataAccess.READ],
      );
      if (!ok) {
        state = state.copyWith(connected: false);
        return false;
      }
      await _ref.read(sharedPrefsProvider).setBool(_key, true);
      state = state.copyWith(connected: true, clearError: true);
      await refresh();
      return true;
    } catch (e) {
      debugPrint('Health connect: $e');
      state = state.copyWith(error: '$e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _health.revokePermissions();
    } catch (_) {}
    await _ref.read(sharedPrefsProvider).setBool(_key, false);
    state = WatchData(availability: state.availability);
  }

  /// Bugungi ma'lumotlarni o'qiydi. Har bir tur alohida — bittasi bo'lmasa, qolganlari baribir chiqadi.
  Future<void> refresh() async {
    if (!state.connected || state.syncing) return;
    state = state.copyWith(syncing: true, clearError: true);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int? steps;
    int? hr;
    int? resting;
    int? sleep;
    int? active;
    double? weight;

    try {
      steps = await _health.getTotalStepsInInterval(today, now);
    } catch (e) {
      debugPrint('Health steps: $e');
    }

    Future<List<HealthDataPoint>> read(HealthDataType t, DateTime from) async {
      try {
        return _health.removeDuplicates(
          await _health.getHealthDataFromTypes(
            types: [t],
            startTime: from,
            endTime: now,
          ),
        );
      } catch (e) {
        debugPrint('Health $t: $e');
        return const [];
      }
    }

    num? latest(List<HealthDataPoint> points) {
      if (points.isEmpty) return null;
      points.sort((a, b) => a.dateTo.compareTo(b.dateTo));
      final v = points.last.value;
      return v is NumericHealthValue ? v.numericValue : null;
    }

    hr = latest(
      await read(
        HealthDataType.HEART_RATE,
        now.subtract(const Duration(hours: 24)),
      ),
    )?.round();
    resting = latest(
      await read(
        HealthDataType.RESTING_HEART_RATE,
        now.subtract(const Duration(days: 7)),
      ),
    )?.round();

    final energy = await read(HealthDataType.ACTIVE_ENERGY_BURNED, today);
    if (energy.isNotEmpty) {
      active = energy
          .map((p) => p.value)
          .whereType<NumericHealthValue>()
          .fold<num>(0, (s, v) => s + v.numericValue)
          .round();
    }

    // Uyqu: kecha 18:00 dan hozirgacha boshlangan sessiyalar.
    final sleepPoints = await read(
      Platform.isIOS
          ? HealthDataType.SLEEP_ASLEEP
          : HealthDataType.SLEEP_SESSION,
      today.subtract(const Duration(hours: 6)),
    );
    if (sleepPoints.isNotEmpty) {
      sleep = sleepPoints.fold<int>(
        0,
        (s, p) => s + p.dateTo.difference(p.dateFrom).inMinutes,
      );
    }

    final weightPoints = await read(
      HealthDataType.WEIGHT,
      now.subtract(const Duration(days: 90)),
    );
    weight = latest(weightPoints)?.toDouble();
    if (weight != null) _importWeight(weight, weightPoints.last.dateTo);

    state = state.copyWith(
      syncing: false,
      lastSync: now,
      steps: steps,
      heartRate: hr,
      restingHeartRate: resting,
      sleepMinutes: sleep,
      activeKcal: active,
      weightKg: weight,
    );
  }

  /// Tarozi / Samsung Health'dagi yangi vazn — vazn tarixiga ham qo'shiladi.
  void _importWeight(double kg, DateTime at) {
    final log = _ref.read(weightLogProvider);
    final last = log.isEmpty ? null : log.last;
    if (last != null && !at.isAfter(last.date)) return;
    _ref
        .read(weightLogProvider.notifier)
        .add(double.parse(kg.toStringAsFixed(1)), at: at);
  }
}
