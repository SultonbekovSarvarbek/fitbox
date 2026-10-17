import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_tabs.dart';
import '../../core/widgets/primary_button.dart';
import '../setup/setup_profile.dart';
import '../workout/data/met.dart';
import '../workout/data/workout_models.dart';
import '../workout/widgets/routine_card.dart';
import 'data/progress_models.dart';

part 'progress_screen_widgets.dart';

/// 7.2 Progress tracking: 7.2.2 Progress Charts (statistika) · 7.2.1 Workout Log.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(l10n.progress, style: AppTextStyles.h2),
      ),
      floatingActionButton: _tab == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: const CircleBorder(),
              onPressed: () => _addManualEntry(context, ref),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: Column(
        children: [
          PillTabs(
            labels: [l10n.progressCharts, l10n.workoutLog],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _tab == 0 ? const _StatsTab() : const _LogTab()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Statistika
// ---------------------------------------------------------------------------
