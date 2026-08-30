import 'package:flutter/material.dart';

/// Colors ported 1:1 from the original HTML's Tailwind config
/// (Material 3 color roles: surface / primary / secondary / tertiary / error).
class AppColors {
  AppColors._();

  static const surfaceTint = Color(0xFF3056C4);
  static const secondary = Color(0xFF735C00);
  static const onPrimaryFixedVariant = Color(0xFF093CAB);
  static const onBackground = Color(0xFF0B1C30);
  static const background = Color(0xFFF8F9FF);
  static const secondaryFixedDim = Color(0xFFF0C100);
  static const primary = Color(0xFF002576);
  static const inversePrimary = Color(0xFFB6C4FF);
  static const tertiaryFixed = Color(0xFFFFDAD7);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const onSurfaceVariant = Color(0xFF444653);
  static const onTertiaryFixedVariant = Color(0xFF930015);
  static const onTertiaryContainer = Color(0xFFFF918B);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const onError = Color(0xFFFFFFFF);
  static const onPrimaryFixed = Color(0xFF00164F);
  static const error = Color(0xFFBA1A1A);
  static const surface = Color(0xFFF8F9FF);
  static const onTertiary = Color(0xFFFFFFFF);
  static const inverseSurface = Color(0xFF213145);
  static const tertiaryContainer = Color(0xFF8C0014);
  static const tertiaryFixedDim = Color(0xFFFFB3AE);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const inverseOnSurface = Color(0xFFEAF1FF);
  static const secondaryContainer = Color(0xFFFECC00);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const secondaryFixed = Color(0xFFFFE089);
  static const primaryFixed = Color(0xFFDCE1FF);
  static const onTertiaryFixed = Color(0xFF410004);
  static const onSecondaryFixedVariant = Color(0xFF574500);
  static const onSecondaryContainer = Color(0xFF6E5700);
  static const outline = Color(0xFF747685);
  static const onSecondaryFixed = Color(0xFF241A00);
  static const tertiary = Color(0xFF62000A);
  static const primaryFixedDim = Color(0xFFB6C4FF);
  static const onPrimaryContainer = Color(0xFF96ADFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const onSurface = Color(0xFF0B1C30);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const outlineVariant = Color(0xFFC4C5D5);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFD3E4FE);
  static const errorContainer = Color(0xFFFFDAD6);
  static const primaryContainer = Color(0xFF0038A8);
  static const onErrorContainer = Color(0xFF93000A);

  // A couple of one-off accents used in the original HTML (green status chips)
  static const successGreen = Color(0xFF15803D);
  static const successGreenBg = Color(0xFFDCFCE7);
}

class AppTextStyles {
  AppTextStyles._();

  static const labelSm = TextStyle(
      fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500);
  static const labelMd = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.7,
      fontWeight: FontWeight.w600);
  static const headlineMd =
      TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600);
  static const bodySm =
      TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const headlineSm =
      TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600);
  static const headlineLg = TextStyle(
      fontSize: 32,
      height: 40 / 32,
      letterSpacing: -0.64,
      fontWeight: FontWeight.w700);
  static const bodyMd =
      TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const bodyLg =
      TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w400);
  static const titleSm =
      TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600);
  static const titleMd =
      TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600);
  static const titleLg =
      TextStyle(fontSize: 18, height: 26 / 18, fontWeight: FontWeight.w600);
}
