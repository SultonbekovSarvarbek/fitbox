import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shrift: Plus Jakarta Sans — ilova ichida (`assets/fonts/PlusJakartaSans.ttf`, variable).
/// Variable shriftda qalinlik `wght` o'qi orqali beriladi, shuning uchun `_w()` ishlatiladi.
/// Jakarta'da kirill harflari yo'q — ular Manrope'dan olinadi (`fontFallback`).
abstract final class AppTextStyles {
  static const fontFamily = 'PlusJakartaSans';

  /// Jakarta'da yo'q harflar (kirill) shu shriftdan olinadi.
  static const fontFallback = ['Manrope'];

  static TextStyle _w(
    double size,
    int weight, {
    Color color = AppColors.textPrimary,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation('wght', weight.toDouble())],
    color: color,
  );

  /// Katta, qalin, UPPERCASE sarlavhalar ("PEACH PALACE", "LET'S GET TO…").
  static TextStyle get display => _w(34, 800).copyWith(height: 1.05);
  static TextStyle get h1 => _w(28, 800);
  static TextStyle get h2 => _w(22, 700);
  static TextStyle get h3 => _w(18, 700);
  static TextStyle get title => _w(15, 600);
  static TextStyle get body => _w(14, 400);
  static TextStyle get bodySecondary =>
      _w(14, 400, color: AppColors.textSecondary);
  static TextStyle get caption => _w(12, 500);
  static TextStyle get captionSecondary =>
      _w(12, 500, color: AppColors.textSecondary);
  static TextStyle get overline =>
      _w(11, 600, color: AppColors.textSecondary).copyWith(letterSpacing: 0.8);
  static TextStyle get button => _w(15, 700);
}
