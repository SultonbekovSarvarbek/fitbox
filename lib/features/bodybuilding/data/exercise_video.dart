import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locale/locale_provider.dart';
import 'bb_models.dart';

/// Mashq texnikasi videolari — YouTube qidiruvi orqali (server va kalit kerak emas).
/// O'zbek tilida sifatli video kam, shuning uchun uz → ruscha so'rov.
Uri techniqueVideoUri(BbExercise e, String lang) {
  final query = switch (lang) {
    'en' => '${e.name.en} proper form technique',
    _ => '${e.name.ru} техника выполнения',
  };
  return Uri.https('www.youtube.com', '/results', {'search_query': query});
}

/// YouTube ilovasida (yoki brauzerda) ochadi.
Future<void> openTechniqueVideo(BuildContext context, BbExercise e) async {
  final uri = techniqueVideoUri(
    e,
    Localizations.localeOf(context).languageCode,
  );
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.videoOpenFailed)));
  }
}
