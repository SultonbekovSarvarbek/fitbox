import 'package:flutter/material.dart';

/// Umumiy animatsiya vaqtlari — hamma joyda bir xil "his" bo'lishi uchun.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 600);

  /// Ketma-ket chiqadigan elementlar orasidagi kechikish.
  static const stagger = Duration(milliseconds: 70);

  static const curve = Curves.easeOutCubic;
}

/// Ekranga kirishda pastdan yumshoq chiqib keladi (fade + slide).
/// `index` — ketma-ketlikdagi o'rni (stagger uchun).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 24,
    this.duration = AppMotion.slow,
    this.delay = Duration.zero,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;

  /// Qo'shimcha boshlang'ich kechikish (stagger'dan tashqari).
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration);
  late final _a = CurvedAnimation(parent: _c, curve: AppMotion.curve);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay + AppMotion.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _a.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Bosganda biroz kichrayadi — tugma va kartalar uchun "jonli" his.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.scale = 0.96});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Raqamni 0 dan berilgan qiymatgacha "sanab" ko'rsatadi.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: AppMotion.curve,
      builder: (context, v, _) => builder(context, v),
    );
  }
}
