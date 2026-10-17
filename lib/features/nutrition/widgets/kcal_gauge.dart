import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// design/1.png (o'ng telefon) — yarim doira kaloriya o'lchagichi.
class KcalGauge extends StatelessWidget {
  const KcalGauge({
    super.key,
    required this.value,
    required this.child,
    this.height = 150,
  });

  /// 0..1
  final double value;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) =>
            CustomPaint(painter: _GaugePainter(v), child: child),
        child: Align(alignment: const Alignment(0, 0.75), child: child),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final radius = math.min(size.width / 2, size.height) - stroke / 2;
    final center = Offset(size.width / 2, size.height - 4);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bg);
    if (value > 0) canvas.drawArc(rect, math.pi, math.pi * value, false, fg);

    // Uchidagi kichik nuqta (rasmdagidek).
    final angle = math.pi + math.pi * value;
    final tip = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(tip, 5, Paint()..color = AppColors.textOnPrimary);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
