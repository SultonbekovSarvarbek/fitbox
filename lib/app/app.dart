import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/locale/locale_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/motivation/data/motivation_providers.dart';
import '../features/setup/setup_profile.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userPersistenceProvider);
    ref.watch(reminderSyncProvider);
    return MaterialApp.router(
      title: 'Forkout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
