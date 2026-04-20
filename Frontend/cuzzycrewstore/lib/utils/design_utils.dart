import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cuzzycrewstore/utils/colorUtils.dart';

class DesignUtils {
  static const BorderRadius zeroRadius = BorderRadius.zero;
  static const double topBarHeight = 64;

  static double topBarActionIconSize(double width) {
    return width < 640
        ? (width * 0.060).clamp(20.0, 24.0).toDouble()
        : (width * 0.015).clamp(22.0, 28.0).toDouble();
  }

  static ButtonStyle topBarIconButtonStyle({required bool isDark}) {
    return IconButton.styleFrom(
      minimumSize: const Size.square(42),
      maximumSize: const Size.square(42),
      fixedSize: const Size.square(42),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
      backgroundColor:
          isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
      foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
      overlayColor: AppColors.primaryAccent.withValues(alpha: 0.10),
      splashFactory: NoSplash.splashFactory,
    );
  }

  static TextStyle topBarTitleStyle({
    required bool isDark,
    required double fontSize,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.bebasNeue(
      color: isDark ? AppColors.darkText : AppColors.lightText,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle topBarLogoStyle({
    required bool isDark,
    required double fontSize,
  }) {
    return GoogleFonts.bebasNeue(
      color: isDark ? AppColors.darkText : AppColors.lightText,
      fontSize: fontSize,
      letterSpacing: 2.6,
      height: 1,
    );
  }

  static EdgeInsets pagePadding(double width) {
    if (width < 640) {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
    if (width < 1024) {
      return const EdgeInsets.symmetric(horizontal: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 30);
  }

  static List<BoxShadow> hardShadow({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark ? AppColors.amber800 : AppColors.ink950,
        offset: const Offset(4, 4),
        blurRadius: 0,
      ),
    ];
  }

  static BoxDecoration hardSurface({required bool isDark, Color? color}) {
    return BoxDecoration(
      color: color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 2,
      ),
      borderRadius: zeroRadius,
      boxShadow: hardShadow(isDark: isDark),
    );
  }

  static bool canRenderAssetImage(String path) {
    final trimmed = path.trim();
    return trimmed.isNotEmpty &&
        !trimmed.startsWith('http') &&
        !trimmed.endsWith('/') &&
        trimmed.contains('.');
  }

  static Color heroOverlayStart() => AppColors.darkBase.withValues(alpha: 0.82);

  static Color heroOverlayMiddle() =>
      AppColors.darkBase.withValues(alpha: 0.48);

  static Color heroOverlayEnd() => AppColors.darkBase.withValues(alpha: 0.22);
}
