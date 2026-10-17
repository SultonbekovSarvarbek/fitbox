import 'package:fitness_app/features/bodybuilding/data/bb_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Epley 1RM', () {
    expect(estimate1Rm(100, 1), 100);
    expect(estimate1Rm(100, 5), closeTo(116.7, 0.1));
    expect(estimate1Rm(80, 10), closeTo(106.7, 0.1));
    expect(estimate1Rm(0, 5), 0);
  });

  test('progressiv yuklama: hamma setda yuqori chegara → +2.5 kg', () {
    final next = suggestNextWeight(
      lastSets: const [
        SetResult(weightKg: 60, reps: 12),
        SetResult(weightKg: 60, reps: 12),
        SetResult(weightKg: 60, reps: 12),
      ],
      repsMax: 12,
      lowerBody: false,
    );
    expect(next, 62.5);
  });

  test('oyoq: +5 kg', () {
    final next = suggestNextWeight(
      lastSets: const [
        SetResult(weightKg: 100, reps: 8),
        SetResult(weightKg: 100, reps: 8),
      ],
      repsMax: 8,
      lowerBody: true,
    );
    expect(next, 105);
  });

  test('bitta setda yetmasa — og\'irlik o\'zgarmaydi', () {
    final next = suggestNextWeight(
      lastSets: const [
        SetResult(weightKg: 60, reps: 12),
        SetResult(weightKg: 60, reps: 10),
      ],
      repsMax: 12,
      lowerBody: false,
    );
    expect(next, 60);
  });

  test('hajm va format', () {
    expect(
      volumeOf(const [
        SetResult(weightKg: 60, reps: 10),
        SetResult(weightKg: 62.5, reps: 8),
      ]),
      1100,
    );
    expect(formatKg(62.5), '62.5');
    expect(formatKg(60), '60');
  });
}
