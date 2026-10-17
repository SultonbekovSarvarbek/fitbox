import 'dart:async';
import '../../core/assets/app_icons.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import 'data/food_models.dart';
import 'widgets/scan_overlay.dart';

enum _Stage { camera, analyzing, result }

/// "+" → ovqatni skanerlash: kamera → avtomatik kadr → AI tahlil → natija → jurnalga.
class FoodScanScreen extends ConsumerStatefulWidget {
  const FoodScanScreen({super.key});

  @override
  ConsumerState<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends ConsumerState<FoodScanScreen>
    with SingleTickerProviderStateMixin {
  static const _autoCapture = Duration(seconds: 3);

  CameraController? _camera;
  String? _cameraError;
  var _stage = _Stage.camera;
  File? _photo;
  FoodScanResult? _result;

  /// Avtomatik suratga olish hisobi (tugma atrofidagi halqa).
  late final _countdown =
      AnimationController(vsync: this, duration: _autoCapture)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) _capture();
        });

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw CameraException('NoCamera', null);
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted) return c.dispose();
      setState(() => _camera = c);
      _countdown.forward(from: 0);
    } on CameraException catch (e) {
      if (mounted) setState(() => _cameraError = e.code);
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized || _stage != _Stage.camera) return;
    _countdown.stop();
    HapticFeedback.mediumImpact();
    try {
      final shot = await c.takePicture();
      await _analyze(File(shot.path));
    } on CameraException catch (e) {
      debugPrint('FoodScan: ${e.code}');
    }
  }

  Future<void> _pickFromGallery() async {
    _countdown.stop();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (picked == null) {
      if (_stage == _Stage.camera) _countdown.forward(from: 0);
      return;
    }
    await _analyze(File(picked.path));
  }

  Future<void> _analyze(File image) async {
    // Rasmni ilova papkasiga ko'chiramiz — jurnalda ko'rinadi.
    final dir = await getApplicationDocumentsDirectory();
    final saved = await image.copy(
      '${dir.path}/food_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    if (!mounted) return;
    setState(() {
      _photo = saved;
      _stage = _Stage.analyzing;
    });
    final result = await ref
        .read(foodRecognizerProvider)
        .recognize(
          saved,
          languageCode: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _result = result;
      _stage = _Stage.result;
    });
  }

  void _retake() {
    _photo?.delete().ignore();
    setState(() {
      _photo = null;
      _result = null;
      _stage = _Stage.camera;
    });
    _countdown.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = _camera;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fon: jonli kamera yoki olingan rasm.
          if (_photo != null)
            Image.file(_photo!, fit: BoxFit.cover)
          else if (c != null && c.value.isInitialized)
            _CoverPreview(controller: c)
          else if (_cameraError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  l10n.cameraUnavailable,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ),

          if (_stage != _Stage.result)
            ScanOverlay(analyzing: _stage == _Stage.analyzing),

          // Yuqori panel — tepaga yopishgan, ostida qorong'i gradient (yorug' rasmda ham o'qiladi).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Color(0x00000000)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.close_rounded,
                        background: AppColors.black.withValues(alpha: 0.5),
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aiFoodScan.toUpperCase(),
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              l10n.whatAreYouEating,
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pastki qism — bosqichga qarab.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(a),
                    child: child,
                  ),
                ),
                child: switch (_stage) {
                  _Stage.camera => _CameraControls(
                    key: const ValueKey('camera'),
                    countdown: _countdown,
                    onShutter: _capture,
                    onGallery: _pickFromGallery,
                    onManual: () async {
                      _countdown.stop();
                      final added = await showManualFoodSheet(context, ref);
                      if (!context.mounted) return;
                      if (added) {
                        context.pop();
                      } else {
                        _countdown.forward(from: 0);
                      }
                    },
                  ),
                  _Stage.analyzing => const _Analyzing(
                    key: ValueKey('analyzing'),
                  ),
                  _Stage.result => _ResultPanel(
                    key: const ValueKey('result'),
                    result: _result!,
                    photoPath: _photo?.path,
                    onRetake: _retake,
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraControls extends StatelessWidget {
  const _CameraControls({
    super.key,
    required this.countdown,
    required this.onShutter,
    required this.onGallery,
    required this.onManual,
  });

  final AnimationController countdown;
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(l10n.placeFoodInFrame, style: AppTextStyles.caption),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundAction(
                icon: Icons.photo_library_rounded,
                label: l10n.gallery,
                onTap: onGallery,
              ),
              GestureDetector(
                onTap: onShutter,
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: AnimatedBuilder(
                    animation: countdown,
                    builder: (_, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: countdown.value,
                            strokeWidth: 4,
                            color: AppColors.primary,
                            backgroundColor: AppColors.white.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        Container(
                          width: 66,
                          height: 66,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const SvgIcon(
                            AppIcons.addFood,
                            color: AppColors.textOnPrimary,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _RoundAction(
                icon: Icons.edit_note_rounded,
                label: l10n.manualEntry,
                onTap: onManual,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleIconButton(
          icon: icon,
          size: 52,
          background: AppColors.black.withValues(alpha: 0.55),
          onTap: onTap,
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

/// "AI tahlil qilmoqda…" — nuqtalar navbat bilan yonadi.
class _Analyzing extends StatefulWidget {
  const _Analyzing({super.key});

  @override
  State<_Analyzing> createState() => _AnalyzingState();
}

class _AnalyzingState extends State<_Analyzing>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AppCard(
        color: AppColors.black.withValues(alpha: 0.7),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(context.l10n.aiAnalyzing, style: AppTextStyles.title),
            ),
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) => Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                          alpha: ((_c.value * 3 - i) % 3) < 1 ? 1 : 0.25,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Natija: nom, kaloriya (sanab chiqadi), makrolar, porsiya, ovqat turi → "Qo'shish".
class _ResultPanel extends ConsumerStatefulWidget {
  const _ResultPanel({
    super.key,
    required this.result,
    required this.photoPath,
    required this.onRetake,
  });

  final FoodScanResult result;
  final String? photoPath;
  final VoidCallback onRetake;

  @override
  ConsumerState<_ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends ConsumerState<_ResultPanel> {
  static const _portions = [0.5, 1.0, 1.5, 2.0];
  double _portion = 1;
  late MealSlot _slot = slotForNow();

  int _scaled(int v) => (v * _portion).round();

  void _add() {
    final r = widget.result;
    ref
        .read(foodLogProvider.notifier)
        .add(
          FoodEntry(
            date: DateTime.now(),
            name: r.name,
            kcal: _scaled(r.kcal),
            protein: _scaled(r.protein),
            carbs: _scaled(r.carbs),
            fat: _scaled(r.fat),
            slot: _slot,
            photoPath: widget.photoPath,
          ),
        );
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.foodAdded(_scaled(r.kcal)))),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.result;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.isDemo)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          l10n.demoResult,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    Text(r.name, style: AppTextStyles.h2),
                    Text(
                      l10n.aiConfidence((r.confidence * 100).round()),
                      style: AppTextStyles.captionSecondary,
                    ),
                  ],
                ),
              ),
              CountUp(
                value: _scaled(r.kcal).toDouble(),
                duration: const Duration(milliseconds: 900),
                builder: (_, v) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${v.round()}',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(l10n.kcalLabel, style: AppTextStyles.captionSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Macro(
                label: l10n.protein,
                grams: _scaled(r.protein),
                color: AppColors.yellow,
                of: 60,
              ),
              const SizedBox(width: AppSpacing.sm),
              _Macro(
                label: l10n.carbs,
                grams: _scaled(r.carbs),
                color: AppColors.green,
                of: 90,
              ),
              const SizedBox(width: AppSpacing.sm),
              _Macro(
                label: l10n.fat,
                grams: _scaled(r.fat),
                color: AppColors.orange,
                of: 40,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.portion, style: AppTextStyles.captionSecondary),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final p in _portions)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _Choice(
                      label: '×${p == p.roundToDouble() ? p.round() : p}',
                      selected: _portion == p,
                      onTap: () => setState(() => _portion = p),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in MealSlot.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _Choice(
                      label: s.label(context),
                      selected: _slot == s,
                      onTap: () => setState(() => _slot = s),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.retake,
                  variant: ButtonVariant.secondary,
                  icon: Icons.refresh_rounded,
                  onPressed: widget.onRetake,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: l10n.addToDiary,
                  icon: Icons.add_rounded,
                  onPressed: _add,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({
    required this.label,
    required this.grams,
    required this.color,
    required this.of,
  });

  final String label;
  final int grams;
  final Color color;

  /// Shkala uchun taxminiy maksimal (bir ovqatga).
  final int of;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.captionSecondary),
            const SizedBox(height: 4),
            Text('$grams g', style: AppTextStyles.title.copyWith(color: color)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (grams / of).clamp(0, 1)),
                duration: const Duration(milliseconds: 900),
                curve: AppMotion.curve,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  color: color,
                  backgroundColor: AppColors.border,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.title.copyWith(
            fontSize: 13,
            color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

extension MealSlotL10n on MealSlot {
  String label(BuildContext context) => switch (this) {
    MealSlot.breakfast => context.l10n.breakfast,
    MealSlot.lunch => context.l10n.lunch,
    MealSlot.dinner => context.l10n.dinner,
    MealSlot.snack => context.l10n.snack,
  };
}

/// Qo'lda qo'shish: nom + kkal (+ ixtiyoriy makrolar). Qo'shilsa `true`.
Future<bool> showManualFoodSheet(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final name = TextEditingController();
  final kcal = TextEditingController();
  var slot = slotForNow();

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
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
            Text(l10n.manualEntry, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: name,
              autofocus: true,
              style: AppTextStyles.body,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(hintText: l10n.foodName),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: kcal,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.body,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: l10n.kcalLabel,
                suffixText: l10n.kcalLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              children: [
                for (final s in MealSlot.values)
                  _Choice(
                    label: s.label(ctx),
                    selected: slot == s,
                    onTap: () => setSheet(() => slot = s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: l10n.addToDiary,
              expanded: true,
              onPressed: () {
                final k = int.tryParse(kcal.text);
                if (name.text.trim().isEmpty || k == null || k <= 0) return;
                ref
                    .read(foodLogProvider.notifier)
                    .add(
                      FoodEntry(
                        date: DateTime.now(),
                        name: name.text.trim(),
                        kcal: k,
                        protein: 0,
                        carbs: 0,
                        fat: 0,
                        slot: slot,
                      ),
                    );
                Navigator.pop(ctx, true);
              },
            ),
          ],
        ),
      ),
    ),
  );
  name.dispose();
  kcal.dispose();
  return ok ?? false;
}

/// Kamera tasviri ekranni to'ldiradi, lekin cho'zilmaydi: nisbat saqlanadi,
/// ortiqcha qismi qirqiladi (telefon kamerasidagi kabi).
class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // CameraPreview portretda o'zi 1 / aspectRatio nisbatda chiziladi.
        final previewRatio = 1 / controller.value.aspectRatio;
        final screenRatio = box.maxWidth / box.maxHeight;
        final scale = previewRatio < screenRatio
            ? screenRatio / previewRatio
            : previewRatio / screenRatio;
        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}
