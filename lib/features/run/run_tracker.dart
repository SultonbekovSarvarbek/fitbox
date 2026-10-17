import 'dart:math' as math;

import '../workout/data/met.dart';

/// Yugurish rejimi — GPS'dan mustaqil, sof hisob-kitob (unit-test qilinadi).
/// GPS va UI `run_screen.dart`da.

enum RunActivity {
  run(maxSpeedKmh: 30),
  walk(maxSpeedKmh: 12),
  bike(maxSpeedKmh: 70);

  const RunActivity({required this.maxSpeedKmh});

  /// Bundan tez "sakrash" — GPS xatosi, hisobga olinmaydi.
  final double maxSpeedKmh;

  /// Tezlikka qarab MET — Compendium of Physical Activities (taxminiy).
  double metAt(double speedKmh) {
    if (speedKmh < 1) return 1.0; // to'xtab turish — faol sarf yo'q
    switch (this) {
      case RunActivity.walk:
        if (speedKmh < 3.2) return 2.0;
        if (speedKmh < 4.8) return 3.0;
        if (speedKmh < 5.6) return 3.5;
        if (speedKmh < 6.4) return 4.3;
        return 5.0;
      case RunActivity.run:
        if (speedKmh < 6.4) return 4.3; // tez yurish
        if (speedKmh < 8.0) return 7.0;
        if (speedKmh < 9.7) return 8.3;
        if (speedKmh < 11.3) return 9.8;
        if (speedKmh < 12.9) return 11.0;
        if (speedKmh < 14.5) return 11.8;
        if (speedKmh < 16.1) return 12.8;
        return 14.5;
      case RunActivity.bike:
        if (speedKmh < 16) return 4.0;
        if (speedKmh < 19) return 6.8;
        if (speedKmh < 22) return 8.0;
        if (speedKmh < 25.7) return 10.0;
        return 12.0;
    }
  }
}

/// Bitta GPS nuqta.
class GeoPoint {
  const GeoPoint(this.lat, this.lon, this.time, {this.accuracy = 5});

  final double lat;
  final double lon;
  final DateTime time;

  /// Metr — GPS aniqligi.
  final double accuracy;
}

/// Ikki nuqta orasidagi masofa (metr) — haversine.
double distanceMeters(GeoPoint a, GeoPoint b) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLon = rad(b.lon - a.lon);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

/// Mashg'ulot hisobchisi: masofa, faol vaqt, kaloriya, temp, yo'l.
class RunSession {
  RunSession({required this.activity, required this.weightKg});

  final RunActivity activity;
  final double weightKg;

  /// Qabul qilingan (filtrlangan) nuqtalar — yo'l chizig'i uchun.
  final List<GeoPoint> route = [];

  double distanceM = 0;
  double kcal = 0;
  Duration active = Duration.zero;

  /// Har bir to'liq km uchun vaqt (km-split'lar).
  final List<Duration> splits = [];
  Duration _lastSplitAt = Duration.zero;

  /// So'nggi ~15 soniya — joriy tezlik (silliqlangan).
  final List<(Duration at, double meters)> _recent = [];

  static const _maxAccuracyM = 30.0;
  static const _window = Duration(seconds: 15);

  /// Joriy tezlik, km/soat.
  double get speedKmh {
    if (_recent.length < 2) return 0;
    final dt = (_recent.last.$1 - _recent.first.$1).inMilliseconds / 3600000;
    if (dt <= 0) return 0;
    final m = _recent.skip(1).fold(0.0, (s, e) => s + e.$2);
    return m / 1000 / dt;
  }

  /// O'rtacha temp — sekund / km (0 — hali ma'lumot yo'q).
  double get avgPaceSecPerKm =>
      distanceM < 50 ? 0 : active.inMilliseconds / 1000 / (distanceM / 1000);

  /// Joriy temp — sekund / km.
  double get currentPaceSecPerKm {
    final v = speedKmh;
    return v < 1 ? 0 : 3600 / v;
  }

  /// Yangi GPS nuqta. Yangi to'liq km tugasa — uning raqamini qaytaradi.
  int? addPoint(GeoPoint p) {
    if (p.accuracy > _maxAccuracyM) return null;
    if (route.isEmpty) {
      route.add(p);
      _recent.add((active, 0));
      return null;
    }
    final last = route.last;
    final d = distanceMeters(last, p);
    final dt = p.time.difference(last.time).inMilliseconds / 1000;
    if (dt <= 0) return null;
    // GPS "sakrashi" — real bo'lmagan tezlik.
    if (d / dt * 3.6 > activity.maxSpeedKmh) return null;
    // Joyida turganda GPS titrashi — aniqlikdan kichik siljish hisobga olinmaydi.
    if (d < math.min(p.accuracy, 8) && dt < 10) return null;

    route.add(p);
    distanceM += d;
    _recent.add((active, d));
    _recent.removeWhere((e) => active - e.$1 > _window);

    final km = (distanceM / 1000).floor();
    if (km > splits.length) {
      splits.add(active - _lastSplitAt);
      _lastSplitAt = active;
      return km;
    }
    return null;
  }

  /// Har soniyada (faqat faol, pauzada emas) chaqiriladi: vaqt va kaloriya.
  void tick(Duration dt) {
    active += dt;
    // Faqat harakatda va faqat faol (net) kaloriya: joyida tursangiz — 0.
    kcal +=
        activeMet(activity.metAt(speedKmh)) *
        weightKg *
        dt.inMilliseconds /
        3600000;
    _recent.removeWhere((e) => active - e.$1 > _window);
  }
}

/// 330 sek → "5:30"
String formatPace(double secPerKm) {
  if (secPerKm <= 0 || secPerKm.isInfinite || secPerKm > 3600) return '--:--';
  final s = secPerKm.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// 3725 sek → "1:02:05", 125 → "02:05"
String formatDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
