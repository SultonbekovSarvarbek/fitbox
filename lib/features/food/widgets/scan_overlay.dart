import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Skaner ramkasi: lime burchaklar + yuqoridan pastga yuruvchi nur.
/// `analyzing` bo'lsa — nur tezlashadi va ramka "nafas oladi".
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key, this.analyzing = false});

  final bool analyzing;

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(ScanOverlay old) {
    super.didUpdateWidget(old);
    if (old.analyzing != widget.analyzing) {
      _c.duration = Duration(milliseconds: widget.analyzing ? 900 : 2200);
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _ScanPainter(
          t: Curves.easeInOut.transform(_c.value),
          analyzing: widget.analyzing,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.t, required this.analyzing});

  final double t;
  final bool analyzing;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width * 0.78;
    final pulse = analyzing ? 1 + 0.03 * t : 1.0;
    final frame = Rect.fromCenter(
      center: size.center(Offset(0, -size.height * 0.06)),
      width: side * pulse,
      height: side * pulse,
    );

    // Ramkadan tashqarini qoraytirish.
    final dim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(28)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      dim,
      Paint()..color = AppColors.black.withValues(alpha: 0.55),
    );

    // Burchaklar.
    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 36.0;
    const r = 28.0;
    for (final (dx, dy) in [(-1, -1), (1, -1), (-1, 1), (1, 1)]) {
      final x = dx < 0 ? frame.left : frame.right;
      final y = dy < 0 ? frame.top : frame.bottom;
      final path = Path()
        ..moveTo(x, y - dy * -len - dy * r)
        ..lineTo(x, y + dy * -r)
        ..arcToPoint(
          Offset(x - dx * r, y),
          radius: const Radius.circular(r),
          clockwise: dx * dy < 0,
        )
        ..lineTo(x - dx * (r + len), y);
      canvas.drawPath(path, corner);
    }

    // Skaner nuri.
    final y = frame.top + 12 + (frame.height - 24) * t;
    final beam = Rect.fromLTRB(frame.left + 16, y - 40, frame.right - 16, y);
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0),
            AppColors.primary.withValues(alpha: 0.35),
          ],
        ).createShader(beam),
    );
    canvas.drawLine(
      Offset(frame.left + 16, y),
      Offset(frame.right - 16, y),
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.t != t || old.analyzing != analyzing;
}
