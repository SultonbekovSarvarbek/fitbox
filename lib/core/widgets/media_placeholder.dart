import 'package:flutter/material.dart';

import '../assets/app_images.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Rasm o'rni. `asset` berilsa va fayl mavjud bo'lsa — rasm (.jpg/.png),
/// aks holda qorong'i gradient + ikon. Yo'llar: `AppImages`.
class MediaPlaceholder extends StatelessWidget {
  const MediaPlaceholder({
    super.key,
    this.icon = Icons.fitness_center_rounded,
    this.asset,
    this.height,
    this.width,
    this.radius = AppRadius.lg,
    this.iconSize = 40,
    this.alignment = Alignment.center,
  });

  final IconData icon;
  final String? asset;

  /// Rasm qaysi qismidan kesiladi (odamli rasmlarda yuz kesilmasligi uchun yuqoriroq).
  final Alignment alignment;
  final double? height;
  final double? width;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.placeholderGradient,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );

    final path = asset == null ? null : AppImages.resolve(asset!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: path == null
            ? fallback
            : LayoutBuilder(
                builder: (context, c) => Image.asset(
                  path,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  // Katta rasmni kichraytirishda tiniqlik saqlansin.
                  filterQuality: FilterQuality.high,
                  // Xotirada ekrandagi o'lchamda saqlanadi (72 px kartochka uchun
                  // 1100 px rasm emas) — xotira va dekodlash vaqti kamayadi.
                  cacheWidth: _decodeWidth(context, c),
                  errorBuilder: (_, _, _) => Image.asset(
                    AppImages.alternate(path),
                    fit: BoxFit.cover,
                    alignment: alignment,
                    errorBuilder: (_, _, _) => fallback,
                  ),
                ),
              ),
      ),
    );
  }

  /// Dekodlash eni: `cover` uchun rasm tik (portret) deb olinadi — eni
  /// kartochkaning eng katta tomonidan kam bo'lmasin. Cheksiz o'lchamda — asl.
  static int? _decodeWidth(BuildContext context, BoxConstraints c) {
    final side = [
      c.maxWidth,
      c.maxHeight,
    ].where((v) => v.isFinite).fold<double>(0, (a, b) => a > b ? a : b);
    if (side == 0) return null;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (side * dpr * 1.1).ceil();
  }
}

/// Kinematik rang: kontrast biroz yuqori, ranglar biroz so'nik, iliq ohang
/// (kino kadridagi kabi). Barcha katta rasmlarga bir xil qo'llanadi.
final ColorFilter cinematicGrade = ColorFilter.matrix(_gradeMatrix());

List<double> _gradeMatrix({
  double contrast = 1.1,
  double saturation = 0.95,
  double warm = 7,
}) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final s = saturation, c = contrast;
  final t = 128 * (1 - c);
  // Avval to'yinganlik, keyin kontrast; oxirida iliq siljish (R+, B−).
  List<double> row(double r, double g, double b, double offset) => [
    c * r,
    c * g,
    c * b,
    0,
    t + offset,
  ];
  return [
    ...row(lr * (1 - s) + s, lg * (1 - s), lb * (1 - s), warm),
    ...row(lr * (1 - s), lg * (1 - s) + s, lb * (1 - s), warm * 0.3),
    ...row(lr * (1 - s), lg * (1 - s), lb * (1 - s) + s, -warm),
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Rasm + kinematik ishlov (rang, vinyetka, chuqur soya) + ustida kontent.
/// [motion] — sekin "Ken Burns" yaqinlashuvi (katta hero rasmlar uchun).
class ImageCard extends StatefulWidget {
  const ImageCard({
    super.key,
    required this.child,
    this.icon = Icons.fitness_center_rounded,
    this.asset,
    this.height,
    this.width,
    this.radius = AppRadius.lg,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.motion = false,
  });

  final Widget child;
  final IconData icon;
  final String? asset;
  final double? height;
  final double? width;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool motion;

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _kenBurns;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (widget.motion && !reduce && _kenBurns == null) {
      _kenBurns = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 16),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _kenBurns?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = ColorFiltered(
      colorFilter: cinematicGrade,
      child: MediaPlaceholder(
        icon: widget.icon,
        asset: widget.asset,
        radius: 0,
        iconSize: 72,
        // Hero kartalarda odam yuzi yuqorida — markazdan biroz tepadan kesamiz.
        alignment: const Alignment(0, -0.4),
      ),
    );
    final kb = _kenBurns;
    if (kb != null) {
      image = AnimatedBuilder(
        animation: kb,
        builder: (_, child) {
          final v = Curves.easeInOut.transform(kb.value);
          return Transform.scale(
            scale: 1.0 + 0.04 * v,
            // Sekin siljish: biroz o'ngga-yuqoriga suriladi.
            alignment: Alignment(-0.3 + 0.6 * v, -0.2),
            child: child,
          );
        },
        child: image,
      );
      image = RepaintBoundary(child: image);
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            const ColoredBox(color: AppColors.imageOverlay),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.05,
                  colors: AppColors.imageVignette,
                  stops: [0.55, 1],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, -0.45),
                  colors: AppColors.imageScrimTop,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0, -0.1),
                  end: Alignment.bottomCenter,
                  colors: AppColors.imageScrim,
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Padding(padding: widget.padding, child: widget.child),
            if (widget.onTap != null)
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: widget.onTap),
              ),
          ],
        ),
      ),
    );
  }
}
