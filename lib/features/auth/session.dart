import 'package:shared_preferences/shared_preferences.dart';

/// Kirgan foydalanuvchini eslab qolish (DEMO: token o'rniga bayroq).
/// Kirish bosqichlari: telefon → SMS kod → (yangi bo'lsa) Set Up anketasi → Home.
/// `signedIn` anketa tugagach `true` bo'ladi — keyingi ochilishda to'g'ri Home'ga o'tiladi.
///
/// TODO(backend): haqiqiy tokenlar (`/auth/otp/verify`), akkaunt ro'yxati serverda.
abstract final class Session {
  static const _signedIn = 'signed_in';
  static const _phone = 'session_phone';
  static const _accounts = 'accounts';
  static const _setupDone = 'setup_done';

  static bool isSignedIn(SharedPreferences prefs) =>
      prefs.getBool(_signedIn) ?? false;

  /// Joriy akkauntning raqami (`+998…`), kirmagan bo'lsa `null`.
  static String? phone(SharedPreferences prefs) => prefs.getString(_phone);

  static bool isRegistered(SharedPreferences prefs, String phone) =>
      (prefs.getStringList(_accounts) ?? const []).contains(phone);

  /// Yangi akkaunt ochiladi (SMS tasdiqlangach).
  static Future<void> register(SharedPreferences prefs, String phone) async {
    final all = {...?prefs.getStringList(_accounts), phone};
    await prefs.setStringList(_accounts, all.toList());
  }

  /// Seans boshlanadi, lekin anketa tugamaguncha "kirgan" hisoblanmaydi.
  static Future<void> start(SharedPreferences prefs, String phone) =>
      prefs.setString(_phone, phone);

  /// Anketa to'ldirilgan akkauntmi (qayta kirganda anketaga qaytarilmaydi).
  static bool setupDone(SharedPreferences prefs, String phone) =>
      (prefs.getStringList(_setupDone) ?? const []).contains(phone);

  /// Anketa tugadi: foydalanuvchi endi "kirgan".
  static Future<void> signIn(SharedPreferences prefs) async {
    final p = phone(prefs);
    if (p != null) {
      await prefs.setStringList(
        _setupDone,
        {...?prefs.getStringList(_setupDone), p}.toList(),
      );
    }
    await prefs.setBool(_signedIn, true);
  }

  /// Mavjud akkauntga kirish (anketa avval to'ldirilgan).
  static Future<void> resume(SharedPreferences prefs, String phone) async {
    await start(prefs, phone);
    await prefs.setBool(_signedIn, true);
  }

  /// Chiqish: ma'lumotlar telefonda qoladi, qayta kirganda tiklanadi.
  static Future<void> signOut(SharedPreferences prefs) async {
    await prefs.remove(_signedIn);
    await prefs.remove(_phone);
  }

  /// Akkauntni o'chirish: bu akkaunt va unga tegishli hamma narsa o'chadi.
  /// Til tanlovi va boshqa qurilmadagi akkaunt ro'yxati saqlanadi.
  /// TODO(backend): `DELETE /me` (App Store / Play talabi) — server ham o'chiradi.
  static Future<void> deleteAccount(
    SharedPreferences prefs, {
    required String? phone,
  }) async {
    final locale = prefs.getString('locale');
    List<String> without(String key) => [
      for (final p in prefs.getStringList(key) ?? const <String>[])
        if (p != phone) p,
    ];
    final accounts = without(_accounts);
    final done = without(_setupDone);
    await prefs.clear();
    if (locale != null) await prefs.setString('locale', locale);
    if (accounts.isNotEmpty) await prefs.setStringList(_accounts, accounts);
    if (done.isNotEmpty) await prefs.setStringList(_setupDone, done);
  }
}
