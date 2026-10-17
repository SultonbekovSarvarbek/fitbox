import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ilovaning o'z SVG ikonlari (`assets/icons/`). Rang `color` bilan beriladi.
abstract final class AppIcons {
  /// Sabzi — ovqat qo'shish ("+" tugmasi, skaner).
  static const addFood = 'assets/icons/carrot.svg';

  /// Kosada sho'rva (zaxira).
  static const soup = 'assets/icons/soup.svg';
}

/// SVG ikon — `Icon` kabi o'lcham va rang bilan.
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.asset, {super.key, this.size = 24, required this.color});

  final String asset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
