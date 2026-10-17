/// Kaloriya hisobi — standart MET formulasi:
///
///   faol kkal = (MET − 1) × vazn (kg) × vaqt (soat)
///
/// "− 1" — tinch holatdagi sarf (organizm baribir sarflaydi) chiqarib tashlanadi,
/// shunda faqat harakat uchun yoqilgan kaloriya qoladi (Apple "Active calories" kabi).
///
/// MET (Metabolic Equivalent of Task) — mashq og'irligi: tinch o'tirish = 1.
/// Qiymatlar "Compendium of Physical Activities" (Ainsworth va boshq.) bo'yicha
/// taxminiy. Haqiqiy sarf odamga qarab ±20% farq qiladi.
library;

/// Mashq nomidan MET qiymati (kalit so'zlar bo'yicha).
double metFor(String exerciseName) {
  final n = exerciseName.toLowerCase();
  for (final (keys, met) in _table) {
    if (keys.any(n.contains)) return met;
  }
  return 4.0; // o'rtacha kuch mashqi
}

const _table = <(List<String>, double)>[
  (['burpee', 'mountain climber', 'jump squat', 'jumping jack', 'hiit'], 8.0),
  (['pull up', 'pull-up', 'chin up'], 8.0),
  (['deadlift', 'bench press', 'overhead press', 'shoulder press', 'row'], 6.0),
  (['squat', 'lunge', 'dip'], 5.0),
  (['push up', 'push-up', 'pushup', 'crunch', 'sit up'], 3.8),
  (['plank', 'glute bridge', 'calf raise'], 3.5),
  (['stretch', 'cat-cow', 'neck roll', 'yoga', 'mobility'], 2.3),
];

/// Berilgan vaqt uchun kaloriya.
int kcalFor({
  required double met,
  required double weightKg,
  required double minutes,
}) => (activeMet(met) * weightKg * minutes / 60).round();

/// Tinch holatdan ortiq qism (manfiy bo'lmaydi).
double activeMet(double met) => met > 1 ? met - 1 : 0;
