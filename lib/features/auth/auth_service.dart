import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import 'session.dart';

/// Nima uchun kod so'raladi: mavjud akkauntga kirish yoki yangisini ochish.
enum OtpPurpose { login, signup }

enum AuthError { accountNotFound, accountExists, wrongCode, tooManyAttempts }

class AuthException implements Exception {
  const AuthException(this.error);

  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

/// SMS-kod bilan autentifikatsiya. Server (`/auth/otp/request`, `/auth/otp/verify`)
/// bilan ulanganda faqat shu interfeys almashtiriladi.
abstract class AuthRepository {
  /// Kod yuboradi; qayta yuborish uchun kutish soniyalarini qaytaradi.
  Future<int> requestCode(String phone, {required OtpPurpose purpose});

  /// Kodni tekshiradi. Noto'g'ri bo'lsa [AuthException].
  Future<void> verifyCode(String phone, String code);
}

/// DEMO: SMS yuborilmaydi, kod har doim [demoCode]; akkauntlar telefonda saqlanadi.
/// TODO(backend): `ApiAuthRepository` — telefon raqam serverga, token javobda.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._ref);

  final Ref _ref;

  static const demoCode = '123456';
  static const maxAttempts = 5;
  static const resendSeconds = 60;

  int _attempts = 0;

  @override
  Future<int> requestCode(String phone, {required OtpPurpose purpose}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final exists = Session.isRegistered(_ref.read(sharedPrefsProvider), phone);
    if (purpose == OtpPurpose.login && !exists) {
      throw const AuthException(AuthError.accountNotFound);
    }
    if (purpose == OtpPurpose.signup && exists) {
      throw const AuthException(AuthError.accountExists);
    }
    _attempts = 0;
    return resendSeconds;
  }

  @override
  Future<void> verifyCode(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_attempts >= maxAttempts) {
      throw const AuthException(AuthError.tooManyAttempts);
    }
    if (code != demoCode) {
      _attempts++;
      throw const AuthException(AuthError.wrongCode);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DemoAuthRepository(ref),
);
