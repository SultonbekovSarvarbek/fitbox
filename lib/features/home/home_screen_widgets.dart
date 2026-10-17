part of 'home_screen.dart';

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.routine,
    required this.onTap,
    required this.label,
  });

  final Routine routine;
  final VoidCallback onTap;

  /// Chap yuqoridagi yorliq: "Bugungi mashg'ulot" yoki "Kunlik dastur".
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ImageCard(
      motion: true,
      height: 360,
      asset: AppImages.workout(routine.id),
      radius: AppRadius.lg,
      icon: Icons.sports_gymnastics_rounded,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yorliq va ↗ tugmasi — tepada yonma-yon.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(label, style: AppTextStyles.caption),
              ),
              const CircleIconButton(
                icon: Icons.arrow_outward_rounded,
                onTap: _noop,
                background: AppColors.primary,
                foreground: AppColors.textOnPrimary,
                size: 36,
              ),
            ],
          ),
          const Spacer(),
          Text(
            routine.titleOf(context).toUpperCase(),
            style: AppTextStyles.display,
          ),
          if (routine.descriptionOf(context) != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              routine.descriptionOf(context)!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${l10n.minutes(routine.minutes)} · ${l10n.kcal(routine.kcal)}',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}

/// "Bu hafta" — haqiqiy statistika (jurnaldan): kaloriya / haftalik maqsad,
/// mashg'ulotlar, daqiqalar, ketma-ket kunlar. Bosilsa — Natija sahifasi.
/// TODO(sensors): qadam hisoblagich (pedometer) qo'shilganda — qadamlar ham.
class _WeekCard extends ConsumerWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(progressStatsProvider);
    final goal = ref.watch(weeklyKcalGoalProvider);
    final p = (stats.weekKcal / goal).clamp(0.0, 1.0);

    return AppCard(
      onTap: () => context.go(Routes.progress),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.thisWeek, style: AppTextStyles.title)),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CountUp(
            value: stats.weekKcal.toDouble(),
            builder: (_, v) => Text.rich(
              TextSpan(
                text: '${v.round()}',
                style: AppTextStyles.h1,
                children: [
                  TextSpan(
                    text: ' / ${l10n.kcal(goal)}',
                    style: AppTextStyles.captionSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: p),
              duration: const Duration(milliseconds: 1100),
              curve: AppMotion.curve,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 12,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _WeekStat(
                value: '${stats.weekWorkouts}',
                label: l10n.workoutsLabel,
              ),
              _WeekStat(
                value: '${stats.weekMinutes}',
                label: l10n.minutesLabel,
              ),
              _WeekStat(
                value: '${stats.streakDays} 🔥',
                label: l10n.streakLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h3),
          Text(label, style: AppTextStyles.captionSecondary),
        ],
      ),
    );
  }
}

/// Soatdan: bugungi qadamlar (10 000 maqsad), puls, uyqu. Bosilsa — qurilmalar sahifasi.
class _WatchStrip extends StatelessWidget {
  const _WatchStrip({required this.data});

  final WatchData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const goal = 10000;
    final steps = data.steps ?? 0;
    final sleep = data.sleepMinutes;
    return AppCard(
      onTap: () => context.push(Routes.devices),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.watch_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.fromYourWatch, style: AppTextStyles.title),
              ),
              if (data.syncing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUp(
                value: steps.toDouble(),
                builder: (_, v) =>
                    Text('${v.round()}', style: AppTextStyles.h1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  '/ $goal ${l10n.steps.toLowerCase()}',
                  style: AppTextStyles.captionSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: (steps / goal).clamp(0, 1).toDouble(),
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _WatchStat(
                icon: Icons.favorite_rounded,
                color: AppColors.error,
                value: data.heartRate == null
                    ? '—'
                    : '${data.heartRate} ${l10n.bpm}',
              ),
              _WatchStat(
                icon: Icons.bedtime_rounded,
                color: AppColors.purple,
                value: sleep == null
                    ? '—'
                    : l10n.sleepDuration(sleep ~/ 60, sleep % 60),
              ),
              _WatchStat(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.orange,
                value: data.activeKcal == null
                    ? '—'
                    : l10n.kcal(data.activeKcal!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatchStat extends StatelessWidget {
  const _WatchStat({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Katta karta karuseli: 1-sahifa — bugungi mashg'ulot, keyingilari — kunlik dastur.
/// Pastda sahifa nuqtalari; qo'shni karta chetdan ko'rinib turadi (surish mumkinligi seziladi).
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.routines});

  final List<Routine> routines;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = widget.routines;
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? AppSpacing.lg : AppSpacing.xs,
                right: i == items.length - 1 ? AppSpacing.lg : AppSpacing.xs,
              ),
              child: _HeroCard(
                routine: items[i],
                label: i == 0 ? l10n.todaysWorkout : l10n.dailyProgram,
                onTap: () => context.go(Routes.routine(items[i].id)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.primary
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Bo'limlar" — ilovaning barcha asosiy qismlari: ikon + nom, 4 ustun.
class _SectionsGrid extends ConsumerWidget {
  const _SectionsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // go — Asosiy tab ichidagi sahifalar (pastki menyu qoladi), push — to'liq ekran.
    final items = <(IconData, String, VoidCallback, int)>[
      (
        Icons.sports_gymnastics_rounded,
        l10n.workout,
        () => context.go(Routes.workout),
        0,
      ),
      (
        Icons.fitness_center_rounded,
        l10n.bodybuilding,
        () => context.push(Routes.bodybuilding),
        0,
      ),
      (
        Icons.directions_run_rounded,
        l10n.sectionRun,
        () => context.push(Routes.run),
        0,
      ),
      (
        Icons.restaurant_rounded,
        l10n.nutrition,
        () => context.go(Routes.nutrition),
        0,
      ),
      (
        Icons.insights_rounded,
        l10n.progress,
        () => context.go(Routes.progress),
        0,
      ),
      (
        Icons.groups_rounded,
        l10n.community,
        () => context.go(Routes.community),
        ref.watch(unreadCommunityProvider),
      ),
      (
        Icons.storefront_rounded,
        l10n.market,
        () => context.push(Routes.market),
        0,
      ),
      (
        Icons.menu_book_rounded,
        l10n.sectionGuide,
        () => context.push(Routes.guide),
        0,
      ),
    ];
    return Column(
      children: [
        for (var row = 0; row < items.length; row += 4) ...[
          if (row > 0) const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = row; i < row + 4; i++) ...[
                if (i > row) const SizedBox(width: AppSpacing.sm),
                Expanded(child: _SectionTile(item: items[i])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.item});

  final (IconData, String, VoidCallback, int) item;

  @override
  Widget build(BuildContext context) {
    final (icon, label, onTap, badge) = item;
    return PressableScale(
      child: AppCard(
        onTap: onTap,
        radius: AppRadius.md,
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
        child: Column(
          children: [
            CountBadge(
              count: badge,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
