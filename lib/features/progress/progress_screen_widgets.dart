part of 'progress_screen.dart';

class _StatsTab extends ConsumerWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(progressStatsProvider);
    final cards = <Widget>[
      _WeeklyGoalCard(stats: stats, goal: ref.watch(weeklyKcalGoalProvider)),
      const _DailyKcalChart(),
      const _ActivityCalendar(),
      const _WeeklyMinutesChart(),
      const _WeightCard(),
      const _LevelSplitCard(),
      AppCard(
        child: Row(
          children: [
            _BigStat(
              icon: Icons.fitness_center_rounded,
              value: '${stats.totalWorkouts}',
              label: l10n.totalWorkouts,
            ),
            const SizedBox(width: AppSpacing.md),
            _BigStat(
              icon: Icons.local_fire_department_rounded,
              value: NumberFormat.decimalPattern(
                Localizations.localeOf(context).toString(),
              ).format(stats.totalKcal),
              label: l10n.totalKcal,
            ),
          ],
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => FadeSlideIn(index: i, child: cards[i]),
    );
  }
}

/// Karta sarlavhasi: nom + o'ng tomonda qiymat.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.captionSecondary),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.stats, required this.goal});

  final ProgressStats stats;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = goal == 0 ? 0.0 : stats.weekKcal / goal;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: p),
              duration: const Duration(milliseconds: 1200),
              curve: AppMotion.curve,
              builder: (_, v, _) => CustomPaint(
                painter: _RingPainter(v.clamp(0, 1)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(v * 100).round()}%', style: AppTextStyles.h1),
                      SizedBox(
                        width: 84,
                        child: Text(
                          l10n.weeklyGoal,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: AppTextStyles.captionSecondary.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountUp(
                  value: stats.weekKcal.toDouble(),
                  builder: (_, v) => Text.rich(
                    TextSpan(
                      text: '${v.round()}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                      ),
                      children: [
                        TextSpan(
                          text: ' / $goal',
                          style: AppTextStyles.captionSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(l10n.kcalThisWeek, style: AppTextStyles.captionSecondary),
                const SizedBox(height: AppSpacing.md),
                _MiniStat(
                  icon: Icons.fitness_center_rounded,
                  text: l10n.workoutsCount(stats.weekWorkouts),
                ),
                _MiniStat(
                  icon: Icons.schedule_rounded,
                  text: l10n.minutes(stats.weekMinutes),
                ),
                _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  text: l10n.streakDays(stats.streakDays),
                  color: AppColors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [AppColors.green, AppColors.primary],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, 2 * math.pi, false, bg);
    if (value > 0) {
      canvas.drawArc(arc, -math.pi / 2, 2 * math.pi * value, false, fg);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

/// Kunlik kaloriya — 7 kun, kunlik maqsad chizig'i bilan.
class _DailyKcalChart extends ConsumerWidget {
  const _DailyKcalChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kcal = ref.watch(weeklyKcalProvider);
    final dailyGoal = ref.watch(weeklyKcalGoalProvider) / 7;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final labels = [
      for (var i = 6; i >= 0; i--)
        DateFormat.E(locale).format(now.subtract(Duration(days: i))),
    ];
    final maxY = math
        .max(dailyGoal * 1.6, kcal.reduce(math.max) * 1.2)
        .toDouble();
    final avg = kcal.where((k) => k > 0).isEmpty
        ? 0
        : kcal.where((k) => k > 0).reduce((a, b) => a + b) ~/
              kcal.where((k) => k > 0).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: l10n.dailyCalories,
            subtitle: l10n.avgPerActiveDay(avg),
            trailing: _Legend(
              color: AppColors.textSecondary,
              label: l10n.dailyGoalLabel,
              dashed: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: dailyGoal,
                      color: AppColors.textSecondary,
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceLight,
                    getTooltipItem: (g, _, rod, _) => BarTooltipItem(
                      l10n.kcal(rod.toY.round()),
                      AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 4,
                      getTitlesWidget: (v, meta) => v == meta.max
                          ? const SizedBox.shrink()
                          : Text(
                              '${v.round()}',
                              style: AppTextStyles.captionSecondary,
                            ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          labels[v.toInt()],
                          style: v.toInt() == 6
                              ? AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                )
                              : AppTextStyles.captionSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (final (i, k) in kcal.indexed)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: k.toDouble(),
                          width: 20,
                          color: k >= dailyGoal
                              ? AppColors.primary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: AppColors.background.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 14 : 10,
          height: dashed ? 2 : 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(dashed ? 1 : 3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.captionSecondary),
      ],
    );
  }
}

/// Oxirgi 5 hafta faolligi — GitHub uslubidagi issiqlik xaritasi.
class _ActivityCalendar extends ConsumerWidget {
  const _ActivityCalendar();

  static const _days = 35;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kcal = ref.watch(dailyKcalProvider(_days));
    final maxK = math.max(1, kcal.reduce(math.max));
    final active = kcal.where((k) => k > 0).length;
    final locale = Localizations.localeOf(context).toString();
    final today = DateTime.now();
    // Ustunlar dushanbadan boshlansin: birinchi katakni haftaning kuniga moslaymiz.
    final first = today.subtract(const Duration(days: _days - 1));
    final lead = first.weekday - 1;

    Color cell(int k) {
      if (k == 0) return AppColors.surfaceLight;
      final t = k / maxK;
      return AppColors.primary.withValues(alpha: 0.25 + 0.75 * t);
    }

    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (final (i, k) in kcal.indexed)
        Tooltip(
          message:
              '${DateFormat.MMMd(locale).format(first.add(Duration(days: i)))} · ${l10n.kcal(k)}',
          child: Container(
            decoration: BoxDecoration(
              color: cell(k),
              borderRadius: BorderRadius.circular(6),
              border: i == _days - 1
                  ? Border.all(color: AppColors.white, width: 1.5)
                  : null,
            ),
          ),
        ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: l10n.activityCalendar,
            subtitle: l10n.activeDaysOf(active, _days),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var d = 0; d < 7; d++)
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat.E(locale)
                          .format(DateTime(2024, 1, 1 + d))
                          .substring(0, 1)
                          .toUpperCase(),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: cells,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(l10n.less, style: AppTextStyles.captionSecondary),
              const SizedBox(width: 6),
              for (final k in [0, maxK ~/ 4, maxK ~/ 2, maxK])
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: cell(k),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(width: 2),
              Text(l10n.more, style: AppTextStyles.captionSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

/// 8 haftalik trend — mashg'ulot daqiqalari.
class _WeeklyMinutesChart extends ConsumerWidget {
  const _WeeklyMinutesChart();

  static const _weeks = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mins = ref.watch(weeklyMinutesProvider(_weeks));
    final maxY = math.max(60, mins.reduce(math.max)) * 1.25;
    final last = mins.last;
    final prev = mins[mins.length - 2];
    final change = prev == 0 ? null : ((last - prev) / prev * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: l10n.weeklyActivity,
            subtitle: l10n.minutesPerWeek,
            trailing: change == null ? null : _ChangeChip(percent: change),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY.toDouble(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceLight,
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          l10n.minutes(s.y.round()),
                          AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 4,
                      getTitlesWidget: (v, meta) => v == meta.max
                          ? const SizedBox.shrink()
                          : Text(
                              '${v.round()}',
                              style: AppTextStyles.captionSecondary,
                            ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          v.toInt() == _weeks - 1
                              ? l10n.thisWeekShort
                              : '-${_weeks - 1 - v.toInt()}',
                          style: AppTextStyles.captionSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (final (i, m) in mins.indexed)
                        FlSpot(i.toDouble(), m.toDouble()),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      getDotPainter: (s, _, _, i) => FlDotCirclePainter(
                        radius: i == _weeks - 1 ? 5 : 3,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({
    required this.percent,
    this.lowerIsBetter = false,
    this.label,
  });

  final num percent;
  final bool lowerIsBetter;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final good = lowerIsBetter ? percent <= 0 : percent >= 0;
    final color = good ? AppColors.green : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percent >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label ?? '${percent > 0 ? '+' : ''}$percent%',
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Vazn dinamikasi + vazn qo'shish.
class _WeightCard extends ConsumerWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = ref.watch(weightLogProvider);
    final locale = Localizations.localeOf(context).toString();
    final current = entries.isEmpty
        ? ref.watch(userProvider).weightKg.toDouble()
        : entries.last.kg;
    final diff = entries.length < 2 ? null : current - entries.first.kg;

    final values = entries.map((e) => e.kg);
    final minY = entries.isEmpty
        ? 0.0
        : (values.reduce(math.min) - 1).floorToDouble();
    final maxY = entries.isEmpty
        ? 1.0
        : (values.reduce(math.max) + 1).ceilToDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: l10n.weightProgress,
            subtitle: entries.isEmpty
                ? null
                : l10n.sinceDate(
                    DateFormat.MMMd(locale).format(entries.first.date),
                  ),
            trailing: diff == null
                ? null
                : _ChangeChip(
                    percent: double.parse(diff.toStringAsFixed(1)),
                    lowerIsBetter: !{
                      Goal.gainWeight,
                      Goal.muscleMass,
                    }.contains(ref.watch(userProvider).goal),
                    label:
                        '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} ${l10n.kg}',
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              text: current.toStringAsFixed(1),
              style: AppTextStyles.h1,
              children: [
                TextSpan(
                  text: ' ${l10n.kg}',
                  style: AppTextStyles.captionSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (entries.length >= 2)
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: _weightStep(minY, maxY),
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.surfaceLight,
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem(
                            '${entries[s.x.toInt()].kg} ${l10n.kg}\n',
                            AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                            children: [
                              TextSpan(
                                text: DateFormat.MMMd(
                                  locale,
                                ).format(entries[s.x.toInt()].date),
                                style: AppTextStyles.captionSecondary,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: _weightStep(minY, maxY),
                        getTitlesWidget: (v, meta) =>
                            v == meta.min || v == meta.max
                            ? const SizedBox.shrink()
                            : Text(
                                '${v.round()}',
                                style: AppTextStyles.captionSecondary,
                              ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (final (i, e) in entries.indexed)
                          FlSpot(i.toDouble(), e.kg),
                      ],
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: AppColors.white,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        getDotPainter: (s, _, _, i) => FlDotCirclePainter(
                          radius: i == entries.length - 1 ? 5 : 2.5,
                          color: i == entries.length - 1
                              ? AppColors.primary
                              : AppColors.white,
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.white.withValues(alpha: 0.18),
                            AppColors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(l10n.addWeightHint, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.addWeight,
            icon: Icons.add_rounded,
            variant: ButtonVariant.secondary,
            expanded: true,
            compact: true,
            onPressed: () => _addWeight(context, ref, current),
          ),
        ],
      ),
    );
  }
}

/// Vazn o'qi uchun qadam: 1, 2 yoki 5 kg — 3–5 ta chiziq bo'lishi uchun.
double _weightStep(double min, double max) {
  final range = max - min;
  if (range <= 5) return 1;
  if (range <= 10) return 2;
  return 5;
}

Future<void> _addWeight(
  BuildContext context,
  WidgetRef ref,
  double current,
) async {
  final l10n = context.l10n;
  final controller = TextEditingController(text: current.toStringAsFixed(1));
  final kg = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addWeight, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: AppTextStyles.h2,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(suffixText: l10n.kg),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.saveRoutine,
            expanded: true,
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '.'));
              if (v != null && v >= 30 && v <= 300) Navigator.pop(ctx, v);
            },
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  if (kg != null) ref.read(weightLogProvider.notifier).add(kg);
}

/// Daraja bo'yicha taqsimot — doiraviy diagramma.
class _LevelSplitCard extends ConsumerWidget {
  const _LevelSplitCard();

  static const _colors = {
    ActivityLevel.beginner: AppColors.green,
    ActivityLevel.intermediate: AppColors.primary,
    ActivityLevel.advanced: AppColors.orange,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final split = ref.watch(levelSplitProvider);
    final total = split.values.fold(0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: l10n.byLevel),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 38,
                        startDegreeOffset: -90,
                        sections: [
                          for (final MapEntry(key: level, value: n)
                              in split.entries)
                            if (n > 0)
                              PieChartSectionData(
                                value: n.toDouble(),
                                color: _colors[level],
                                radius: 18,
                                showTitle: false,
                              ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$total', style: AppTextStyles.h2),
                        Text(
                          l10n.workoutsLabel,
                          style: AppTextStyles.captionSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    for (final MapEntry(key: level, value: n) in split.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            _Legend(
                              color: _colors[level]!,
                              label: level.label(context),
                            ),
                            const Spacer(),
                            Text(
                              '${(n / total * 100).round()}%',
                              style: AppTextStyles.title,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(child: Text(value, style: AppTextStyles.h3)),
                Text(label, style: AppTextStyles.captionSecondary, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Jurnal
// ---------------------------------------------------------------------------

class _LogTab extends ConsumerWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final log = ref.watch(workoutLogProvider);
    final locale = Localizations.localeOf(context).toString();

    if (log.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_note_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.noWorkoutsYet,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.startFirstWorkout,
                onPressed: () => context.go(Routes.workout),
              ),
            ],
          ),
        ),
      );
    }

    String dayLabel(DateTime d) {
      final today = DateUtils.dateOnly(DateTime.now());
      final diff = today.difference(DateUtils.dateOnly(d)).inDays;
      if (diff == 0) return l10n.today;
      if (diff == 1) return l10n.yesterday;
      return DateFormat.MMMMEEEEd(locale).format(d);
    }

    final items = <Widget>[];
    String? lastLabel;
    for (final e in log) {
      final label = dayLabel(e.date);
      if (label != lastLabel) {
        lastLabel = label;
        items.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(label.toUpperCase(), style: AppTextStyles.overline),
          ),
        );
      }
      final level = ActivityLevel.values
          .where((l) => l.name == e.level)
          .firstOrNull;
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (_LevelSplitCard._colors[level] ?? AppColors.primary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: _LevelSplitCard._colors[level] ?? AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.titleOf(context), style: AppTextStyles.title),
                      Text(
                        [
                          DateFormat.Hm(locale).format(e.date),
                          if (level != null) level.label(context),
                        ].join(' · '),
                        style: AppTextStyles.captionSecondary,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.kcal(e.kcal),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      l10n.minutes(e.minutes),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 96),
      children: items,
    );
  }
}

/// Qo'lda yozuv: qaysi mashg'ulot va necha daqiqa — kaloriya formula bilan.
Future<void> _addManualEntry(BuildContext context, WidgetRef ref) async {
  final picked = await showModalBottomSheet<Routine>(
    context: context,
    builder: (ctx) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        for (final r in ref.read(routinesProvider))
          ListTile(
            title: Text(r.titleOf(context), style: AppTextStyles.body),
            subtitle: Text(
              '${ctx.l10n.minutes(r.minutes)} · ${ctx.l10n.kcal(r.kcal)}',
              style: AppTextStyles.captionSecondary,
            ),
            onTap: () => Navigator.pop(ctx, r),
          ),
      ],
    ),
  );
  if (picked == null) return;
  final weight = ref.read(userProvider).weightKg.toDouble();
  ref
      .read(workoutLogProvider.notifier)
      .add(
        LogEntry(
          date: DateTime.now(),
          title: picked.title,
          routineId: picked.id,
          minutes: picked.minutes,
          kcal: kcalFor(
            met: picked.met,
            weightKg: weight,
            minutes: picked.minutes.toDouble(),
          ),
          level: picked.level.name,
        ),
      );
}
