import 'package:flutter/material.dart';

/// ★ RANGLAR ROOT — ilovadagi barcha ranglar faqat shu yerda.
/// Hech bir widget ichida `Color(0x...)` yozilmaydi, faqat `AppColors.x`.
///
/// Manba: design/1.png, design/2.png (qora fon + neon-lime aksent).
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFDCFF2B); // neon-lime — tugmalar, aktiv holat

  // Fon va sirtlar
  static const background = Color(0xFF0B0B0B);
  static const surface = Color(0xFF1A1A1A); // kartalar
  static const surfaceLight = Color(0xFF262626); // chip, input, ichki kartalar
  static const border = Color(0xFF2E2E2E);

  // Matn
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const textOnPrimary = Color(0xFF0B0B0B);

  // Makro / holat ranglari (Nutrition kartalari)
  static const green = Color(0xFF34C759);
  static const yellow = Color(0xFFFFD60A);
  static const orange = Color(0xFFFF9F0A);
  static const error = Color(0xFFFF453A);
  static const purple = Color(0xFF8E7CFF); // uyqu

  // Boshqa
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const divider = Color(0xFF2E2E2E);

  /// Rasm yo'q joyda ko'rinadigan gradient.
  static const placeholderGradient = [Color(0xFF2C2C2C), Color(0xFF151515)];

  /// Rasm ustidagi matn o'qilishi uchun pastki qorong'i gradient (kinematik, chuqur).
  static const imageScrim = [
    Color(0x00000000),
    Color(0x73000000),
    Color(0xF2000000),
  ];

  /// Rasm tepasidagi yengil soya — tugmalar va yorliqlar o'qilishi uchun.
  static const imageScrimTop = [Color(0x66000000), Color(0x00000000)];

  /// Kinematik vinyetka — chetlar qorong'ilashadi, nigoh markazga tortiladi.
  static const imageVignette = [Color(0x00000000), Color(0x9E000000)];

  /// Butun rasm ustidagi qora parda — rasm qoraroq, matn va tugmalar ajralib turadi.
  static const imageOverlay = Color(0x1F000000);
}
