import 'package:flutter/services.dart';

/// Rasm yo'llari — bitta joyda. Fayl papkada bo'lmasa, `MediaPlaceholder`
/// avtomatik gradient + ikon ko'rsatadi, shuning uchun rasmlarni bosqichma-bosqich
/// qo'shish mumkin. `.jpg` bo'lmasa, xuddi shu nomdagi `.png` ham qidiriladi.
///
/// Papkalar (pubspec.yaml → assets):
///   assets/images/onboarding/main.jpg (kollaj)
///   assets/images/gender/male.png, female.png
///   assets/images/workouts/{routine id}.jpg   (b1, b2, i1, i2, a1, a2)
///   assets/images/exercises/{mashq-nomi}.jpg  (push-ups, goblet-squat, ...)
///   assets/images/meals/{meal id}.jpg         (m1 … m7)
///   assets/images/resources/{id}.jpg          (a1 … a3, v1 … v4)
abstract final class AppImages {
  static const _root = 'assets/images';

  /// Ilovadagi mavjud rasmlar ro'yxati (AssetManifest) — ishga tushganda bir marta.
  /// Shunda yo'q rasmni har safar ochishga urinib, xato ushlab o'tirilmaydi.
  static Set<String> _available = const {};

  static Future<void> init() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _available = manifest.listAssets().toSet();
    } catch (_) {
      // Manifest o'qilmasa — eski usul: yuklab ko'rib, xatoda zaxira.
    }
  }

  /// Mavjud yo'l (`.jpg` yoki `.png`), yo'q bo'lsa `null`.
  /// Manifest yuklanmagan bo'lsa — yo'lning o'zi (yuklash paytida tekshiriladi).
  static String? resolve(String path) {
    if (_available.isEmpty) return path;
    if (_available.contains(path)) return path;
    final alt = alternate(path);
    return _available.contains(alt) ? alt : null;
  }

  static String onboarding(int i) => '$_root/onboarding/$i.jpg';

  /// Welcome kollaji uchun bitta rasm — 3 ta panelga bo'lib ko'rsatiladi.
  static const onboardingMain = '$_root/onboarding/main.jpg';
  static String gender(String name) => '$_root/gender/$name.png';
  static String workout(String routineId) => '$_root/workouts/$routineId.jpg';
  static String exercise(String name) => '$_root/exercises/${slug(name)}.jpg';
  static String meal(String mealId) => '$_root/meals/$mealId.jpg';
  static String resource(String id) => '$_root/resources/$id.jpg';

  /// "Knee Push Ups" → "knee-push-ups"
  static String slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  /// `.jpg` ↔ `.png` muqobil yo'l.
  static String alternate(String path) => path.endsWith('.jpg')
      ? '${path.substring(0, path.length - 4)}.png'
      : path.endsWith('.png')
      ? '${path.substring(0, path.length - 4)}.jpg'
      : path;
}
