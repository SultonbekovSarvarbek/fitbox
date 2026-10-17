import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../run_tracker.dart';

/// Yo'l chizig'i — xaritasiz: GPS nuqtalari kartaga moslab chiziladi.
/// Boshi — oq nuqta, joriy joy — porlovchi lime nuqta.
class RouteSketch extends StatelessWidget {
  const RouteSketch({super.key, required this.points, this.pulse = 0});

  final List<GeoPoint> points;

  /// 0..1 — joriy nuqta atrofidagi "puls" halqasi (jonli rejimda).
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoutePainter(points, pulse),
      size: Size.infinite,
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.points, this.pulse);

  final List<GeoPoint> points;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    // Fon to'ri — xarita taassuroti.
    final grid = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (points.isEmpty) return;

    // Kenglik/uzunlikni metrga yaqin tekislikka o'tkazamiz (kichik masofada yetarli).
    final lat0 = points.first.lat * math.pi / 180;
    final xs = [for (final p in points) p.lon * math.cos(lat0)];
    final ys = [for (final p in points) p.lat];
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);
    final span = math.max(
      math.max(maxX - minX, maxY - minY),
      0.0004,
    ); // ≥ ~40 m
    const pad = 24.0;
    final scale = math.min(size.width - pad * 2, size.height - pad * 2) / span;
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    Offset map(int i) => Offset(
      size.width / 2 + (xs[i] - cx) * scale,
      size.height / 2 - (ys[i] - cy) * scale,
    );

    final path = Path()..moveTo(map(0).dx, map(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(map(i).dx, map(i).dy);
    }

    // Porlash + asosiy chiziq.
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(map(0), 6, Paint()..color = AppColors.white);
    final head = map(points.length - 1);
    if (pulse > 0) {
      canvas.drawCircle(
        head,
        8 + 18 * pulse,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.35 * (1 - pulse)),
      );
    }
    canvas.drawCircle(head, 8, Paint()..color = AppColors.primary);
    canvas.drawCircle(head, 3.5, Paint()..color = AppColors.textOnPrimary);
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.points.length != points.length || old.pulse != pulse;
}
