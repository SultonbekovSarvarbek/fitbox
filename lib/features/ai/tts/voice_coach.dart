import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/locale/locale_provider.dart';

/// AI · Ovozli ko'rsatma — telefonning o'z TTS'i (bepul, internetsiz).
///
/// Til tanlash: avval ilova tili (uz-UZ / ru-RU / en-US). Telefon o'zbekchani
/// qo'llamasa (ko'p qurilmalarda shunday) — lotin yozuvini to'g'ri o'qiydigan
/// turkcha ovoz, u ham bo'lmasa inglizcha ishlatiladi.
class VoiceCoach {
  VoiceCoach() {
    _tts.awaitSpeakCompletion(false);
    _tts.setSpeechRate(0.5);
  }

  final _tts = FlutterTts();
  String? _language;

  static const _candidates = {
    'uz': ['uz-UZ', 'tr-TR', 'en-US'],
    'ru': ['ru-RU', 'en-US'],
    'en': ['en-US'],
  };

  Future<void> setLocale(Locale locale) async {
    for (final lang in _candidates[locale.languageCode] ?? const ['en-US']) {
      try {
        if (await _tts.isLanguageAvailable(lang) == true) {
          if (_language != lang) await _tts.setLanguage(lang);
          _language = lang;
          return;
        }
      } catch (e) {
        debugPrint('VoiceCoach: $lang tekshirilmadi: $e');
      }
    }
  }

  /// Oldingi gapni to'xtatib, yangisini aytadi.
  Future<void> say(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}

final voiceCoachProvider = Provider<VoiceCoach>((ref) {
  final coach = VoiceCoach();
  ref.onDispose(coach.stop);
  return coach;
});

/// Ovozli ko'rsatma yoqilganmi (Sozlamalar va mashg'ulot sahifasidagi switch).
final voiceEnabledProvider = StateNotifierProvider<VoiceEnabledNotifier, bool>(
  (ref) => VoiceEnabledNotifier(ref),
);

class VoiceEnabledNotifier extends StateNotifier<bool> {
  VoiceEnabledNotifier(this._ref)
    : super(_ref.read(sharedPrefsProvider).getBool(_key) ?? true);

  static const _key = 'voice_enabled';
  final Ref _ref;

  void set(bool value) {
    state = value;
    _ref.read(sharedPrefsProvider).setBool(_key, value);
    if (!value) _ref.read(voiceCoachProvider).stop();
  }
}
