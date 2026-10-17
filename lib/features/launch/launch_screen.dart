import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/widgets/app_logo.dart';
import '../auth/session.dart';
import '../guide/app_tour_screen.dart';

/// 1. Launch
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    final signedIn = Session.isSignedIn(ref.read(sharedPrefsProvider));
    Future.delayed(Duration(milliseconds: signedIn ? 800 : 1500), () {
      if (!mounted) return;
      if (!signedIn) return context.go(Routes.onboarding);
      context.go(tourSeen(ref) ? Routes.home : Routes.tour);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: AppLogo(size: 88)));
  }
}
