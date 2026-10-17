import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

const supportedLocales = [Locale('uz'), Locale('ru'), Locale('en')];

/// main() ichida override qilinadi.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider override qilinmagan'),
);

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(sharedPrefsProvider)),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(Locale(_prefs.getString(_key) ?? 'ru'));

  static const _key = 'locale';
  final SharedPreferences _prefs;

  void set(Locale locale) {
    state = locale;
    _prefs.setString(_key, locale.languageCode);
  }
}

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
