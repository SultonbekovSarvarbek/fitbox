import 'package:fitness_app/features/run/run_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Toshkent atrofida shimolga harakat: 1 m ≈ 0.000008993 kenglik.
GeoPoint at(double metersNorth, int sec, {double acc = 5}) => GeoPoint(
  41.3 + metersNorth * 0.000008993,
  69.24,
  DateTime(2026, 1, 1, 8).add(Duration(seconds: sec)),
  accuracy: acc,
);

void main() {
  test('haversine ≈ 100 m', () {
    expect(distanceMeters(at(0, 0), at(100, 0)), closeTo(100, 0.5));
  });

  test('10 km/soat yugurish: masofa, tezlik, temp, kaloriya', () {
    final s = RunSession(activity: RunActivity.run, weightKg: 70);
    // 10 km/soat = 2.778 m/s — har 3 soniyada nuqta, 10 daqiqa.
    for (var t = 0; t <= 600; t += 3) {
      if (t > 0) s.tick(const Duration(seconds: 3));
      s.addPoint(at(t * 2.7778, t));
    }
    expect(s.distanceM, closeTo(1666.7, 5));
    expect(s.speedKmh, closeTo(10, 0.3));
    expect(formatPace(s.avgPaceSecPerKm), '6:00');
    // faol: (9.8 − 1) × 70 kg × 1/6 soat ≈ 103 kkal
    expect(s.kcal, closeTo(103, 3));
    expect(s.splits.length, 1);
  });

  test('GPS sakrashi va past aniqlik hisobga olinmaydi', () {
    final s = RunSession(activity: RunActivity.run, weightKg: 70);
    s.addPoint(at(0, 0));
    s.addPoint(at(500, 1)); // 1800 km/soat — sakrash
    s.addPoint(at(10, 3, acc: 80)); // aniqlik yomon
    expect(s.distanceM, 0);
    s.addPoint(at(9, 3));
    expect(s.distanceM, closeTo(9, 0.5));
  });

  test('joyida turganda titrash masofa qo\'shmaydi', () {
    final s = RunSession(activity: RunActivity.walk, weightKg: 70);
    for (var t = 0; t < 30; t += 3) {
      s.addPoint(at(t.isEven ? 0 : 3, t));
    }
    expect(s.distanceM, 0);
  });

  test('format', () {
    expect(formatPace(330), '5:30');
    expect(formatPace(0), '--:--');
    expect(formatDuration(const Duration(seconds: 125)), '02:05');
    expect(formatDuration(const Duration(seconds: 3725)), '1:02:05');
  });

  test('joyida turganda kaloriya yoqilmaydi', () {
    final s = RunSession(activity: RunActivity.run, weightKg: 70);
    for (var t = 0; t < 120; t += 3) {
      if (t > 0) s.tick(const Duration(seconds: 3));
      s.addPoint(at(0, t));
    }
    expect(s.kcal, 0);
    expect(s.active, const Duration(seconds: 117));
  });
}
