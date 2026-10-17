import '../../../core/content/content_l10n.dart';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/stored_list.dart';
import '../../nutrition/data/nutrition_models.dart';

enum MealSlot { breakfast, lunch, dinner, snack }

/// Ovqat jurnalidagi bitta yozuv (yeyilgan ovqat).
class FoodEntry {
  const FoodEntry({
    required this.date,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.slot,
    this.photoPath,
  });

  final DateTime date;
  final String name;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final MealSlot slot;

  /// Skanerlangan rasm (ilova papkasida).
  final String? photoPath;

  Map<String, Object?> toJson() => {
    'date': date.toIso8601String(),
    'name': name,
    'kcal': kcal,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'slot': slot.name,
    'photoPath': photoPath,
  };

  static FoodEntry fromJson(Map<String, Object?> j) => FoodEntry(
    date: DateTime.parse(j['date'] as String),
    name: j['name'] as String,
    kcal: (j['kcal'] as num).toInt(),
    protein: (j['protein'] as num?)?.toInt() ?? 0,
    carbs: (j['carbs'] as num?)?.toInt() ?? 0,
    fat: (j['fat'] as num?)?.toInt() ?? 0,
    slot:
        MealSlot.values.where((s) => s.name == j['slot']).firstOrNull ??
        MealSlot.snack,
    photoPath: j['photoPath'] as String?,
  );
}

/// Ovqat jurnali — yangilari tepada, telefonda saqlanadi.
final foodLogProvider = StateNotifierProvider<FoodLogNotifier, List<FoodEntry>>(
  (ref) => FoodLogNotifier(ref),
);

class FoodLogNotifier extends StoredList<FoodEntry> {
  FoodLogNotifier(Ref ref) : super(ref, 'food_log');

  @override
  FoodEntry decode(Map<String, Object?> json) => FoodEntry.fromJson(json);
  @override
  Map<String, Object?> encode(FoodEntry item) => item.toJson();

  void add(FoodEntry e) => save([e, ...state]);

  void remove(FoodEntry e) {
    final path = e.photoPath;
    if (path != null) File(path).delete().ignore();
    save([...state]..remove(e));
  }
}

/// Bugungi ovqatlar.
final todayFoodProvider = Provider<List<FoodEntry>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(foodLogProvider)
      .where(
        (e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day,
      )
      .toList();
});

/// Bugungi jami: kkal, oqsil, uglevod, yog'.
final todayTotalsProvider =
    Provider<({int kcal, int protein, int carbs, int fat})>((ref) {
      final items = ref.watch(todayFoodProvider);
      return (
        kcal: items.fold(0, (s, e) => s + e.kcal),
        protein: items.fold(0, (s, e) => s + e.protein),
        carbs: items.fold(0, (s, e) => s + e.carbs),
        fat: items.fold(0, (s, e) => s + e.fat),
      );
    });

/// Hozirgi soatga qarab ovqat turi.
MealSlot slotForNow([DateTime? at]) {
  final h = (at ?? DateTime.now()).hour;
  if (h < 11) return MealSlot.breakfast;
  if (h < 16) return MealSlot.lunch;
  if (h < 21) return MealSlot.dinner;
  return MealSlot.snack;
}

// ---------------------------------------------------------------------------
// AI · Ovqat rasmidan kaloriya
// ---------------------------------------------------------------------------

/// Bir porsiya uchun tahlil natijasi.
class FoodScanResult {
  const FoodScanResult({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.isDemo = false,
  });

  final String name;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;

  /// 0..1
  final double confidence;

  /// Haqiqiy AI emas, namuna natija.
  final bool isDemo;
}

/// Rasmni tahlil qiluvchi xizmat.
/// Haqiqiy versiya: rasm → o'z serverimiz (`POST /ai/food-scan`) → vision LLM
/// (Claude / GPT / Gemini). API kalit ilovada saqlanmaydi.
abstract interface class FoodRecognizer {
  Future<FoodScanResult> recognize(File image, {required String languageCode});
}

/// Server ulanguncha: rasmni tahlil qilmaydi, namunaviy taomni qaytaradi (`isDemo`).
class DemoFoodRecognizer implements FoodRecognizer {
  final _rnd = math.Random();

  @override
  Future<FoodScanResult> recognize(
    File image, {
    required String languageCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final m = demoMeals[_rnd.nextInt(demoMeals.length)];
    return FoodScanResult(
      name: mealTitles[m.id]?.forCode(languageCode) ?? m.title,
      kcal: m.kcal,
      protein: m.protein,
      carbs: m.carbs,
      fat: m.fat,
      confidence: 0.8 + _rnd.nextDouble() * 0.15,
      isDemo: true,
    );
  }
}

/// TODO(backend): `ServerFoodRecognizer` bilan almashtirish.
final foodRecognizerProvider = Provider<FoodRecognizer>(
  (ref) => DemoFoodRecognizer(),
);
