import 'dart:math' as math;

import 'package:fitness_app/features/ai/pose/pose_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

P _polar(P o, double deg, double len) => (
  x: o.x + len * math.cos(deg * math.pi / 180),
  y: o.y + len * math.sin(deg * math.pi / 180),
);

/// Berilgan tizza va tirsak burchaklariga ega sun'iy kadr.
BodyFrame frame(num kneeDeg, {num elbowDeg = 170}) {
  const knee = (x: 0.0, y: 0.0);
  final ankle = _polar(knee, 90, 100); // pastga
  final hipDir = 90 - kneeDeg.toDouble();
  final hip = _polar(knee, hipDir, 100);
  final shoulder = _polar(hip, hipDir, 120); // tana son bilan bir chiziqda
  final elbow = _polar(shoulder, 90, 80);
  final wrist = _polar(elbow, -90 + elbowDeg.toDouble(), 80);
  return BodyFrame(
    shoulder: shoulder,
    elbow: elbow,
    wrist: wrist,
    hip: hip,
    knee: knee,
    ankle: ankle,
  );
}

void main() {
  test('angleAt — to\'g\'ri burchak', () {
    expect(
      angleAt((x: 1, y: 0), (x: 0, y: 0), (x: 0, y: 1)),
      closeTo(90, 0.001),
    );
    expect(
      angleAt((x: -1, y: 0), (x: 0, y: 0), (x: 1, y: 0)),
      closeTo(180, 0.001),
    );
  });

  test('mashq nomidan aniqlash', () {
    expect(TrackedExercise.fromName('Goblet Squat'), TrackedExercise.squat);
    expect(TrackedExercise.fromName('Knee Push Ups'), TrackedExercise.pushUp);
    expect(TrackedExercise.fromName('Lunges'), TrackedExercise.lunge);
    expect(TrackedExercise.fromName('Plank'), TrackedExercise.plank);
    expect(TrackedExercise.fromName('Neck Rolls'), TrackedExercise.neckRolls);
    expect(
      TrackedExercise.fromName('Jumping Jacks'),
      TrackedExercise.jumpingJacks,
    );
    expect(TrackedExercise.fromName('Shoulder Press'), TrackedExercise.press);
  });

  test('squat: to\'liq tushib-chiqish = 1 takror', () {
    final c = RepCounter(TrackedExercise.squat);
    for (final a in [175.0, 140, 110, 90, 85, 120, 150, 170]) {
      c.step(frame(a));
    }
    expect(c.reps, 1);
    expect(c.lastHint, FormHint.good);
  });

  test('squat: yarim tushish sanalmaydi va "pastroq" maslahati', () {
    final c = RepCounter(TrackedExercise.squat);
    for (final a in [175.0, 140, 125, 140, 170]) {
      c.step(frame(a));
    }
    expect(c.reps, 0);
    expect(c.lastHint, FormHint.goLower);
  });

  test('squat: 3 ta takror', () {
    final c = RepCounter(TrackedExercise.squat);
    for (var i = 0; i < 3; i++) {
      for (final a in [170.0, 120, 85, 120, 170]) {
        c.step(frame(a));
      }
    }
    expect(c.reps, 3);
  });

  test('push-up: tirsak burchagi bo\'yicha sanaladi', () {
    final c = RepCounter(TrackedExercise.pushUp);
    for (final e in [170.0, 120, 80, 120, 165]) {
      c.step(frame(175, elbowDeg: e));
    }
    expect(c.reps, 1);
  });

  test('vaqtli mashq maqsadi soniyadan', () {
    expect(TrackedExercise.plank.targetFor(reps: 0, seconds: 45), 45);
    expect(TrackedExercise.neckRolls.targetFor(reps: 0, seconds: 30), 5);
    expect(TrackedExercise.squat.targetFor(reps: 12), 12);
  });

  BodyFrame plankFrame({double hipDrop = 0}) => BodyFrame(
    shoulder: (x: 0, y: 0),
    elbow: (x: 0, y: 40),
    wrist: (x: 20, y: 40),
    hip: (x: 120, y: hipDrop),
    knee: (x: 180, y: 0),
    ankle: (x: 240, y: 0),
  );

  test('planka: tekis tana vaqti sanaladi', () {
    final h = HoldTimer();
    for (var ms = 0; ms <= 3000; ms += 100) {
      h.update(
        body: plankFrame(),
        t: Duration(milliseconds: ms),
      );
    }
    expect(h.count, 3);
    expect(h.lastHint, FormHint.good);
  });

  test('planka: bel osilib qolsa vaqt to\'xtaydi', () {
    final h = HoldTimer();
    for (var ms = 0; ms <= 3000; ms += 100) {
      h.update(
        body: plankFrame(hipDrop: 60),
        t: Duration(milliseconds: ms),
      );
    }
    expect(h.count, 0);
    expect(h.lastHint, FormHint.keepBodyStraight);
  });

  test('planka: tik turgan odam — holatga o\'ting', () {
    final h = HoldTimer();
    h.update(body: frame(175), t: Duration.zero);
    expect(h.lastHint, FormHint.getInPosition);
  });

  HeadFrame head(double deg, {double r = 25}) => HeadFrame(
    nose: _polar((x: 100, y: -60), deg, r),
    leftShoulder: (x: 0, y: 0),
    rightShoulder: (x: 200, y: 0),
  );

  test('bo\'yin: 3 ta to\'liq aylanish', () {
    final c = CircleCounter();
    // Avval markazda turadi (o'rtacha holat), so'ng aylanadi.
    for (var i = 0; i < 30; i++) {
      c.update(head: head(0, r: 0));
    }
    for (var deg = 0; deg <= 3 * 360 + 20; deg += 15) {
      c.update(head: head(deg.toDouble()));
    }
    expect(c.count, 3);
  });

  test('bo\'yin: qimirlamasa sanalmaydi', () {
    final c = CircleCounter();
    for (var i = 0; i < 60; i++) {
      c.update(head: head(0, r: 2));
    }
    expect(c.count, 0);
    expect(c.lastHint, FormHint.biggerCircles);
  });

  test('jumping jacks: qo\'l ko\'tarib tushirish = 1', () {
    final c = RepCounter(TrackedExercise.jumpingJacks);
    BodyFrame arms(double deg) {
      const shoulder = (x: 0.0, y: 0.0);
      return BodyFrame(
        shoulder: shoulder,
        elbow: _polar(shoulder, 90 - deg, 80),
        wrist: _polar(shoulder, 90 - deg, 160),
        hip: (x: 0, y: 120),
        knee: (x: 0, y: 220),
        ankle: (x: 0, y: 320),
      );
    }

    for (final a in [15.0, 60, 120, 160, 100, 20]) {
      c.step(arms(a.toDouble()));
    }
    expect(c.reps, 1);
  });

  test("bodybuilding nomlari to'g'ri guruhga tushadi", () {
    final cases = {
      'Romanian Deadlift': TrackedExercise.hipHinge,
      'Leg Press': TrackedExercise.legPress,
      'Bench Press': TrackedExercise.press,
      'Hip Thrust': TrackedExercise.gluteBridge,
      'Barbell Curl': TrackedExercise.elbowFlex,
      'Tricep Pushdown': TrackedExercise.elbowFlex,
      'Skull Crusher': TrackedExercise.elbowFlex,
      'Leg Extension': TrackedExercise.kneeFlex,
      'Leg Curl': TrackedExercise.kneeFlex,
      'Seated Cable Row': TrackedExercise.pull,
      'Lat Pulldown': TrackedExercise.pull,
      'Face Pull': TrackedExercise.pull,
      'Chest Dips': TrackedExercise.dips,
      'Standing Calf Raise': TrackedExercise.calfRaise,
      'Hanging Leg Raise': TrackedExercise.hipHinge,
      'Cat-Cow': TrackedExercise.catCow,
      'Mountain Climbers': TrackedExercise.mountainClimbers,
      'Burpees': TrackedExercise.burpees,
      'Hamstring Stretch': TrackedExercise.hamstringStretch,
    };
    cases.forEach((name, want) {
      expect(TrackedExercise.fromName(name), want, reason: name);
    });
    expect(
      TrackedExercise.fromName('Rear Delt Fly'),
      TrackedExercise.lateralRaise,
    );
    expect(TrackedExercise.fromName('Cable Fly'), TrackedExercise.flye);
    expect(TrackedExercise.fromName('Cable Crunch'), TrackedExercise.crunch);
    expect(
      TrackedExercise.fromName('Incline Dumbbell Press'),
      TrackedExercise.press,
    );
    expect(
      TrackedExercise.fromName('Lateral Raise'),
      TrackedExercise.lateralRaise,
    );
  });

  test('mountain climbers: vaqtdan maqsad', () {
    expect(
      TrackedExercise.mountainClimbers.targetFor(reps: 0, seconds: 45),
      31,
    );
  });

  test('oldinga egilish: tizza bukilsa — oyoqni tekis tuting', () {
    final h = HoldTimer(HoldPose.forwardFold);
    h.update(body: frame(120), t: Duration.zero);
    expect(h.lastHint, FormHint.keepLegsStraight);
  });

  test("burun ko'rinmasa cat-cow kadri o'tkaziladi", () {
    final c = RepCounter(TrackedExercise.catCow);
    expect(c.step(frame(175)), isFalse);
    expect(c.reps, 0);
  });
}
