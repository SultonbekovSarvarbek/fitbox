import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/app_reset.dart';
import 'core/assets/app_images.dart';
import 'core/locale/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (prefs, _) = await (
    SharedPreferences.getInstance(),
    AppImages.init(),
  ).wait;
  runApp(
    ValueListenableBuilder<int>(
      valueListenable: appResetEpoch,
      builder: (_, epoch, _) => ProviderScope(
        key: ValueKey(epoch),
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const FitnessApp(),
      ),
    ),
  );
}
