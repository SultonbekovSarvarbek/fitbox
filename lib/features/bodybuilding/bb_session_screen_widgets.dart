part of 'bb_session_screen.dart';

class _SetRow {
  _SetRow({required double weight, required int reps})
    : weight = TextEditingController(text: weight == 0 ? '' : formatKg(weight)),
      reps = TextEditingController(text: '$reps');

  final TextEditingController weight;
  final TextEditingController reps;
  bool done = false;

  SetResult? get result {
    final w = double.tryParse(weight.text.replaceAll(',', '.'));
    final r = int.tryParse(reps.text);
    if (w == null || r == null || r <= 0) return null;
    return SetResult(weightKg: w, reps: r);
  }

  void dispose() {
    weight.dispose();
    reps.dispose();
  }
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    required this.planned,
    required this.rows,
    required this.onToggle,
    required this.onAddSet,
    required this.onChanged,
  });

  final Planned planned;
  final List<_SetRow> rows;
  final ValueChanged<int> onToggle;
  final VoidCallback onAddSet;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ex = planned.exercise;
    final last = ref.watch(lastSetsProvider(planned.key));
    final suggest = suggestNextWeight(
      lastSets: last,
      repsMax: planned.repsMax,
      lowerBody: ex.lowerBody,
    );
    final lastMax = last.isEmpty
        ? 0.0
        : last.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ex.name.of(context), style: AppTextStyles.h3),
              ),
              // AI kamera: takrorlarni sanaydi, natija keyingi setga yoziladi.
              if (TrackedExercise.fromName(ex.name.en) case final tracked?)
                IconButton(
                  tooltip: l10n.aiFormCheck,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openAi(context, tracked),
                  icon: const Icon(
                    Icons.photo_camera_front_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              // Texnikani bilmaganlar uchun — video.
              IconButton(
                tooltip: l10n.techniqueVideo,
                visualDensity: VisualDensity.compact,
                onPressed: () => openTechniqueVideo(context, ex),
                icon: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  ex.muscle.label(context),
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${planned.sets} × ${planned.repsMin}–${planned.repsMax} · ${l10n.restSec(ex.restSec)}',
            style: AppTextStyles.captionSecondary,
          ),
          if (last.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.lastTime}: ${last.map((s) => '${formatKg(s.weightKg)}×${s.reps}').join('  ')}',
                    style: AppTextStyles.captionSecondary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suggest > lastMax)
                  Text(
                    '↑ ${formatKg(suggest)} ${l10n.kg}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(l10n.setCol, style: AppTextStyles.captionSecondary),
              ),
              Expanded(
                child: Text(
                  l10n.kg,
                  style: AppTextStyles.captionSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.repsCol,
                  style: AppTextStyles.captionSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 52),
            ],
          ),
          for (final (i, r) in rows.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text('${i + 1}', style: AppTextStyles.title),
                  ),
                  Expanded(
                    child: _NumField(
                      controller: r.weight,
                      done: r.done,
                      decimal: true,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NumField(
                      controller: r.reps,
                      done: r.done,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => onToggle(i),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: r.done
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: r.done
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onAddSet,
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            label: Text(
              l10n.addSet,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _ExerciseCard {
  /// Kamera ochiladi; sanalgan takrorlar birinchi bajarilmagan set'ga yoziladi
  /// va set bajarildi deb belgilanadi (dam olish taymeri ham boshlanadi).
  Future<void> _openAi(BuildContext context, TrackedExercise tracked) async {
    final i = rows.indexWhere((r) => !r.done);
    final target = i < 0 ? planned.repsMax : int.tryParse(rows[i].reps.text);
    final reps = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => PoseCheckScreen(
          exerciseName: planned.exercise.name.of(context),
          exercise: tracked,
          targetReps: target ?? planned.repsMax,
        ),
      ),
    );
    if (reps == null || reps <= 0 || i < 0) return;
    rows[i].reps.text = '$reps';
    onChanged();
    onToggle(i);
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.done,
    required this.onChanged,
    this.decimal = false,
  });

  final TextEditingController controller;
  final bool done;
  final bool decimal;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        enabled: !done,
        textAlign: TextAlign.center,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
          ),
          LengthLimitingTextInputFormatter(5),
        ],
        cursorColor: AppColors.primary,
        style: AppTextStyles.title.copyWith(
          color: done ? AppColors.primary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          hintText: '0',
          fillColor: done
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceLight,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

/// Dam olish taymeri: qisqarib boruvchi lime chiziq + soniyalar.
class _RestBar extends StatelessWidget {
  const _RestBar({
    super.key,
    required this.left,
    required this.total,
    required this.onSkip,
    required this.onAdd,
  });

  final int left;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      color: AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.restTimer, style: AppTextStyles.title),
              const Spacer(),
              Text(
                formatDuration(Duration(seconds: left)),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextButton(
                onPressed: onAdd,
                child: Text('+30', style: AppTextStyles.title),
              ),
              TextButton(
                onPressed: onSkip,
                child: Text(l10n.skip, style: AppTextStyles.captionSecondary),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : left / total,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          Text(label, style: AppTextStyles.captionSecondary),
        ],
      ),
    );
  }
}
