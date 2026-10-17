/// Bodybuilding — sof hisob-kitob (unit-test qilinadi).
library;

/// Taxminiy bir martalik maksimum — Epley: og'irlik × (1 + takror / 30).
/// 1 takror — og'irlikning o'zi. 12 dan ortiq takrorda formula noaniq, cheklaymiz.
double estimate1Rm(double weightKg, int reps) {
  if (weightKg <= 0 || reps <= 0) return 0;
  if (reps == 1) return weightKg;
  return weightKg * (1 + reps.clamp(1, 12) / 30);
}

/// Bajarilgan set.
class SetResult {
  const SetResult({required this.weightKg, required this.reps});

  final double weightKg;
  final int reps;
}

/// Progressiv yuklama: o'tgan safar shu mashqning HAMMA ishchi setlarida
/// yuqori takror chegarasiga yetilgan bo'lsa — og'irlik oshadi, aks holda o'sha og'irlik.
/// [lowerBody] — oyoq/stanovaya: +5 kg, qolganlari +2.5 kg.
double suggestNextWeight({
  required List<SetResult> lastSets,
  required int repsMax,
  required bool lowerBody,
}) {
  if (lastSets.isEmpty) return 0;
  final weight = lastSets
      .map((s) => s.weightKg)
      .reduce((a, b) => a > b ? a : b);
  final allHit = lastSets.every((s) => s.reps >= repsMax);
  if (!allHit) return weight;
  return weight + (lowerBody ? 5 : 2.5);
}

/// Hajm (tonnaj) = Σ og'irlik × takror.
double volumeOf(Iterable<SetResult> sets) =>
    sets.fold(0.0, (s, e) => s + e.weightKg * e.reps);

/// 62.5 → "62.5", 60.0 → "60"
String formatKg(double kg) =>
    kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
