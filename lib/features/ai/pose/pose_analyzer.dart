import 'dart:math' as math;

/// AI · Kamerada mashqni tekshirish — ML Kit natijasidan mustaqil, sof mantiq
/// (shuning uchun unit-test qilinadi). Kamera va ML Kit `pose_check_screen.dart`da.

/// 2D nuqta (ML Kit landmark koordinatalari, piksel).
typedef P = ({double x, double y});

/// Uch nuqta orasidagi burchak (b — cho'qqi), gradusda 0..180.
double angleAt(P a, P b, P c) {
  final ab = math.atan2(a.y - b.y, a.x - b.x);
  final cb = math.atan2(c.y - b.y, c.x - b.x);
  var deg = ((ab - cb) * 180 / math.pi).abs();
  if (deg > 180) deg = 360 - deg;
  return deg;
}

/// Kuzatish usuli: takror sanash, holatda ushlab turish (soniya), bosh aylanishi.
enum TrackKind { reps, hold, circles }

/// Takror mashqlarida qaysi burchak o'lchanadi.
enum Joint {
  knee,
  elbow,
  hip,
  armRaise,

  /// Tizza–to'piq–oyoq uchi (boldir ko'tarish).
  ankle,

  /// Burun–yelka–son (Cat-Cow: bosh ko'tariladi/tushadi).
  neck,
}

/// Ushlab turiladigan holat turi.
enum HoldPose { plank, forwardFold }

/// Kamera bilan tekshirsa bo'ladigan mashqlar (harakat naqshi bo'yicha guruhlangan:
/// masalan "press" — bench, overhead, shoulder press).
enum TrackedExercise {
  squat(joint: Joint.knee, downBelow: 100, upAbove: 160),
  pushUp(joint: Joint.elbow, downBelow: 90, upAbove: 155),
  lunge(joint: Joint.knee, downBelow: 105, upAbove: 160),
  // Tirsak bukilgan (yelka/ko'krak oldida) → to'liq cho'ziladi.
  press(joint: Joint.elbow, downBelow: 100, upAbove: 155),
  dips(joint: Joint.elbow, downBelow: 100, upAbove: 150),
  // Tortish: qo'l cho'zilgan → tirsak bukiladi → qaytib cho'ziladi.
  pull(joint: Joint.elbow, downBelow: 95, upAbove: 150, partialHint: false),
  // Bitsepsga bukish, triceps pushdown, skull crusher — faqat tirsak ishlaydi.
  elbowFlex(
    joint: Joint.elbow,
    downBelow: 75,
    upAbove: 145,
    partialHint: false,
  ),
  // Deadlift, RDL, osilib oyoq ko'tarish — son bo'g'imida bukilish.
  hipHinge(joint: Joint.hip, downBelow: 115, upAbove: 160, partialHint: false),
  // Yelka–son–tizza: pastda bukilgan, tepada tana tizzagacha tekis.
  gluteBridge(
    joint: Joint.hip,
    downBelow: 145,
    upAbove: 165,
    partialHint: false,
  ),
  legPress(joint: Joint.knee, downBelow: 95, upAbove: 150),
  // Trenajyorda tizzani bukib-yozish (leg extension / leg curl).
  kneeFlex(joint: Joint.knee, downBelow: 100, upAbove: 155, partialHint: false),
  calfRaise(
    joint: Joint.ankle,
    downBelow: 110,
    upAbove: 130,
    partialHint: false,
  ),
  catCow(joint: Joint.neck, downBelow: 125, upAbove: 150, partialHint: false),
  burpees(joint: Joint.knee, downBelow: 100, upAbove: 160, partialHint: false),
  // Son–yelka–tirsak: qo'llar pastda (~15°) → boshdan yuqori (>140°).
  jumpingJacks(
    joint: Joint.armRaise,
    downBelow: 40,
    upAbove: 140,
    partialHint: false,
  ),
  // Qo'llar yonga yelka balandligigacha (lateral raise, rear delt fly).
  lateralRaise(
    joint: Joint.armRaise,
    downBelow: 35,
    upAbove: 75,
    partialHint: false,
  ),
  // Krossoverda qo'llarni oldinga jamlash (kameraga yuzma-yuz).
  flye(joint: Joint.armRaise, downBelow: 55, upAbove: 80, partialHint: false),
  // Tiz cho'kib kabel bilan qorin: son bo'g'imida bukilish.
  crunch(joint: Joint.hip, downBelow: 75, upAbove: 100, partialHint: false),
  // Tizza ko'krakka tortiladi; ko'ringan oyoq sanaladi (~0.7 marta/soniya).
  mountainClimbers(
    joint: Joint.hip,
    downBelow: 120,
    upAbove: 155,
    partialHint: false,
    perSecond: 0.7,
  ),
  plank(kind: TrackKind.hold, hold: HoldPose.plank),
  hamstringStretch(kind: TrackKind.hold, hold: HoldPose.forwardFold),
  neckRolls(kind: TrackKind.circles);

  const TrackedExercise({
    this.kind = TrackKind.reps,
    this.joint = Joint.knee,
    this.downBelow = 0,
    this.upAbove = 180,
    this.partialHint = true,
    this.perSecond = 1,
    this.hold = HoldPose.plank,
  });

  final TrackKind kind;
  final Joint joint;

  /// Asosiy burchak shundan kichik bo'lsa — "pastda".
  final double downBelow;

  /// Shundan katta bo'lsa — "tepada" (takror yakunlandi).
  final double upAbove;

  /// Yarim takrorda "pastroq tushing" deyiladimi.
  final bool partialHint;

  /// Vaqtli takror mashqlarida soniyasiga taxminiy takror (maqsad uchun).
  final double perSecond;

  /// Ushlab turish mashqlarida — qaysi holat.
  final HoldPose hold;

  /// Mashq nomidan aniqlash (inglizcha nom: "Goblet Squat", "Romanian Deadlift"...).
  /// Tartib muhim: "Leg Press" — "press"dan oldin, "Leg Curl" — "curl"dan oldin.
  static TrackedExercise? fromName(String name) {
    final n = name.toLowerCase();
    bool has(List<String> keys) => keys.any(n.contains);
    if (has(['neck roll'])) return neckRolls;
    if (has(['plank'])) return plank;
    if (has(['hamstring stretch', 'toe touch'])) return hamstringStretch;
    if (has(['jumping jack'])) return jumpingJacks;
    if (has(['mountain climber'])) return mountainClimbers;
    if (has(['burpee'])) return burpees;
    if (has(['cat-cow', 'cat cow'])) return catCow;
    if (has(['calf raise'])) return calfRaise;
    if (has(['lateral raise', 'rear delt'])) return lateralRaise;
    if (has(['fly', 'flye'])) return flye;
    if (has(['crunch'])) return crunch;
    if (has(['leg press'])) return legPress;
    if (has(['leg extension', 'leg curl'])) return kneeFlex;
    if (has(['hip thrust', 'glute bridge'])) return gluteBridge;
    if (has(['deadlift', 'leg raise', 'good morning'])) return hipHinge;
    if (has(['squat'])) return squat;
    if (has(['lunge'])) return lunge;
    if (has(['push up', 'push-up', 'pushup'])) return pushUp;
    if (has(['dip'])) return dips;
    if (has(['curl', 'pushdown', 'skull crusher'])) return elbowFlex;
    if (has([
      'pull up',
      'pull-up',
      'pullup',
      'pulldown',
      'chin up',
      'row',
      'face pull',
    ])) {
      return pull;
    }
    if (has(['press'])) return press;
    return null;
  }

  /// Maqsad: takrorlar soni, ushlab turish soniyalari yoki aylanishlar.
  /// Vaqtli mashqlar (Jumping Jacks 30 s) uchun soniyadan hisoblanadi.
  int targetFor({required int reps, int? seconds}) {
    if (seconds == null) return reps;
    return switch (kind) {
      TrackKind.hold => seconds,
      TrackKind.circles => math.max(3, (seconds / 6).ceil()),
      TrackKind.reps => math.max(1, (seconds * perSecond).round()),
    };
  }

  /// Telefon ro'paradan qo'yiladimi (qo'l yon tomonga ochiladigan, bosh mashqlari).
  /// Qolganlari — yon tomondan: bo'g'im burchaklari profilda aniq ko'rinadi.
  bool get frontView => switch (this) {
    jumpingJacks || lateralRaise || flye || neckRolls => true,
    _ => false,
  };

  /// Bu mashq uchun kuzatuvchi.
  ExerciseTracker tracker() => switch (kind) {
    TrackKind.reps => RepCounter(this),
    TrackKind.hold => HoldTimer(hold),
    TrackKind.circles => CircleCounter(),
  };
}

/// Bir kadrdan olingan kerakli bo'g'imlar (yaxshiroq ko'ringan tomon).
class BodyFrame {
  const BodyFrame({
    required this.shoulder,
    required this.elbow,
    required this.wrist,
    required this.hip,
    required this.knee,
    required this.ankle,
    this.nose,
    this.foot,
  });

  final P shoulder, elbow, wrist, hip, knee, ankle;

  /// Ixtiyoriy: burun (Cat-Cow) va oyoq uchi (boldir) — ko'rinmasa `null`.
  final P? nose, foot;

  double get kneeAngle => angleAt(hip, knee, ankle);
  double get elbowAngle => angleAt(shoulder, elbow, wrist);
  double get hipAngle => angleAt(shoulder, hip, knee);
  double get armRaiseAngle => angleAt(hip, shoulder, elbow);

  /// Yelka–son–to'piq: tana to'g'ri chiziqdami (push-up, planka uchun).
  double get bodyLineAngle => angleAt(shoulder, hip, ankle);

  /// Tana yotiq holatdami (yelka va to'piq deyarli bir balandlikda).
  bool get isHorizontal =>
      (shoulder.y - ankle.y).abs() < 0.6 * (shoulder.x - ankle.x).abs();

  /// Kerakli nuqta ko'rinmasa — `null` (kadr o'tkazib yuboriladi).
  double? angleOf(Joint j) => switch (j) {
    Joint.knee => kneeAngle,
    Joint.elbow => elbowAngle,
    Joint.hip => hipAngle,
    Joint.armRaise => armRaiseAngle,
    Joint.ankle => foot == null ? null : angleAt(knee, ankle, foot!),
    Joint.neck => nose == null ? null : angleAt(nose!, shoulder, hip),
  };
}

/// Bosh va yelkalar — bo'yin mashqlari uchun (kameraga yuzma-yuz).
class HeadFrame {
  const HeadFrame({
    required this.nose,
    required this.leftShoulder,
    required this.rightShoulder,
  });

  final P nose, leftShoulder, rightShoulder;
}

/// Shakl bo'yicha ogohlantirish turlari (matni l10n'da).
enum FormHint {
  goLower,
  keepBodyStraight,
  getInPosition,
  bendForward,
  keepLegsStraight,
  biggerCircles,
  good,
}

/// Har xil kuzatuvchilar uchun umumiy interfeys (UI shu bilan ishlaydi).
abstract class ExerciseTracker {
  /// Ekrandagi son: takrorlar, soniyalar yoki aylanishlar.
  int get count;

  /// Oxirgi maslahat (UI va ovoz uchun).
  FormHint? get lastHint;

  /// Bo'yin mashqlari uchun bosh kadri kerakmi (aks holda tana kadri).
  bool get needsHead => false;

  /// Har kadrda chaqiriladi; [t] — kadr vaqti. `count` oshsa `true`.
  bool update({BodyFrame? body, HeadFrame? head, required Duration t});
}

/// Takrorlarni sanovchi holat mashinasi: tepada → pastga tushdi → qaytib chiqdi = +1.
class RepCounter implements ExerciseTracker {
  RepCounter(this.exercise);

  final TrackedExercise exercise;

  int reps = 0;
  bool _down = false;
  double _minAngleThisRep = 180;

  @override
  FormHint? lastHint;

  @override
  int get count => reps;

  @override
  bool get needsHead => false;

  double? primaryAngle(BodyFrame f) => f.angleOf(exercise.joint);

  @override
  bool update({BodyFrame? body, HeadFrame? head, Duration t = Duration.zero}) =>
      body != null && step(body);

  /// Bitta tana kadrini qayta ishlaydi. Yangi takror sanalsa `true`.
  bool step(BodyFrame f) {
    final angle = primaryAngle(f);
    if (angle == null) return false;
    _minAngleThisRep = math.min(_minAngleThisRep, angle);

    if (exercise == TrackedExercise.pushUp && f.bodyLineAngle < 150) {
      lastHint = FormHint.keepBodyStraight;
    }

    if (!_down && angle < exercise.downBelow) {
      _down = true;
    } else if (_down && angle > exercise.upAbove) {
      _down = false;
      reps++;
      if (lastHint != FormHint.keepBodyStraight) lastHint = FormHint.good;
      _minAngleThisRep = 180;
      return true;
    } else if (!_down &&
        angle > exercise.upAbove &&
        _minAngleThisRep < exercise.upAbove - 20) {
      // Tushdi, lekin yetarlicha emas va qaytib chiqdi — takror sanalmaydi.
      if (exercise.partialHint) lastHint = FormHint.goLower;
      _minAngleThisRep = 180;
    }
    return false;
  }
}

/// Ushlab turish: to'g'ri holatda turilgan vaqtgina sanaladi (soniya).
/// Planka — tana yotiq va tekis; oldinga egilish — son bukilgan, tizzalar tekis.
class HoldTimer implements ExerciseTracker {
  HoldTimer([this.pose = HoldPose.plank]);

  final HoldPose pose;

  /// Shundan katta tanaffus (kadr yo'qolsa) hisobga olinmaydi.
  static const maxGap = Duration(milliseconds: 500);

  /// Yelka–son–to'piq shundan to'g'riroq bo'lishi kerak.
  static const straightAbove = 155.0;

  Duration held = Duration.zero;
  Duration? _last;

  @override
  FormHint? lastHint;

  @override
  int get count => held.inSeconds;

  @override
  bool get needsHead => false;

  @override
  bool update({BodyFrame? body, HeadFrame? head, required Duration t}) {
    final last = _last;
    _last = t;
    if (body == null) return false;
    final problem = _check(body);
    lastHint = problem ?? FormHint.good;
    if (problem != null) return false;
    if (last == null) return false;
    final dt = t - last;
    if (dt <= Duration.zero || dt > maxGap) return false;
    final before = held.inSeconds;
    held += dt;
    return held.inSeconds > before;
  }

  /// Holatdagi xato (yo'q bo'lsa `null`).
  FormHint? _check(BodyFrame b) => switch (pose) {
    HoldPose.plank =>
      !b.isHorizontal
          ? FormHint.getInPosition
          : b.bodyLineAngle < straightAbove
          ? FormHint.keepBodyStraight
          : null,
    HoldPose.forwardFold =>
      b.kneeAngle < 150
          ? FormHint.keepLegsStraight
          : b.hipAngle > 115
          ? FormHint.bendForward
          : null,
  };
}

/// Bo'yinni aylantirish: burun yelkalar o'rtasiga nisbatan aylana chizadi.
/// Burchak to'planadi — 360° = 1 aylanish (har ikki yo'nalishda).
class CircleCounter implements ExerciseTracker {
  /// Yelka kengligiga nisbatan shundan kichik siljish — shovqin.
  static const minRadius = 0.05;

  /// Bitta kadrda bundan katta sakrash — xato aniqlash, hisobga olinmaydi.
  static const maxStep = 1.2;

  int circles = 0;
  double _acc = 0;
  double? _prevAngle;
  P? _center;
  int _smallFrames = 0;

  @override
  FormHint? lastHint;

  @override
  int get count => circles;

  @override
  bool get needsHead => true;

  @override
  bool update({BodyFrame? body, HeadFrame? head, Duration t = Duration.zero}) {
    if (head == null) return false;
    final ls = head.leftShoulder, rs = head.rightShoulder;
    final width = math.sqrt(
      math.pow(ls.x - rs.x, 2) + math.pow(ls.y - rs.y, 2),
    );
    if (width < 1) return false;
    final mid = (x: (ls.x + rs.x) / 2, y: (ls.y + rs.y) / 2);
    // Yelka kengligi bilan normallashtiriladi — kameradan masofa ahamiyatsiz.
    final off = (
      x: (head.nose.x - mid.x) / width,
      y: (head.nose.y - mid.y) / width,
    );
    // Aylana markazi — sekin siljiydigan o'rtacha (boshning odatiy holati).
    final c = _center ?? off;
    _center = (x: c.x + 0.05 * (off.x - c.x), y: c.y + 0.05 * (off.y - c.y));
    final v = (x: off.x - c.x, y: off.y - c.y);

    if (math.sqrt(v.x * v.x + v.y * v.y) < minRadius) {
      // Uzoq vaqt deyarli qimirlamasa — "kengroq aylantiring".
      if (++_smallFrames > 45) lastHint = FormHint.biggerCircles;
      return false;
    }
    _smallFrames = 0;
    if (lastHint == FormHint.biggerCircles) lastHint = null;

    final angle = math.atan2(v.y, v.x);
    final prev = _prevAngle;
    _prevAngle = angle;
    if (prev == null) return false;
    var d = angle - prev;
    if (d > math.pi) d -= 2 * math.pi;
    if (d < -math.pi) d += 2 * math.pi;
    if (d.abs() > maxStep) return false;
    // Yo'nalish o'zgarsa — yangi aylanish noldan.
    if (_acc != 0 && d.sign != _acc.sign && d.abs() > 0.15) _acc = 0;
    _acc += d;
    if (_acc.abs() >= 2 * math.pi) {
      _acc -= _acc.sign * 2 * math.pi;
      circles++;
      lastHint = FormHint.good;
      return true;
    }
    return false;
  }
}
