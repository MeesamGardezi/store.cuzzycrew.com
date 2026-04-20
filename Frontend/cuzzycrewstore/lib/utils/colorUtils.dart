import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// not fixed: we can change this acc to figma actual color codes(freestyle way) when we start

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class AppColors {
  static const Color amber950 = Color(0xFF431400);
  static const Color amber900 = Color(0xFF7C2D00);
  static const Color amber800 = Color(0xFFC85F00);
  static const Color amber700 = Color(0xFFEA6C00);
  static const Color amber600 = Color(0xFFF5841F);
  static const Color amber500 = Color(0xFFFB9A3C);
  static const Color amber400 = Color(0xFFFFA94D);
  static const Color amber300 = Color(0xFFFFCC8A);
  static const Color amber200 = Color(0xFFFFE4BA);
  static const Color amber100 = Color(0xFFFFF3E0);
  static const Color amber50 = Color(0xFFFFFAF4);

  static const Color ink950 = Color(0xFF1A0800);
  static const Color ink700 = Color(0xFF5C3410);
  static const Color ink500 = Color(0xFF9A6A3A);
  static const Color paper = Color(0xFFFFF8EE);
  static const Color background = Color(0xFFFFFBF5);

  static const Color semanticSuccess = Color(0xFF16A34A);
  static const Color semanticWarning = Color(0xFFD97706);
  static const Color semanticDanger = Color(0xFFDC2626);

  static const Color slate50 = Color(0xFFF5EAD8);
  static const Color slate400 = Color(0xFFD4AE85);
  static const Color slate500 = Color(0xFF9A6A3A);

  static const Color darkBase = ink950;

  static const Color lightBackground = background;
  static const Color lightSurface = paper;
  static const Color lightSurfaceAlt = amber100;
  static const Color lightBorder = ink950;
  static const Color lightText = ink950;

  static const Color darkBackground = ink950;
  static const Color darkSurface = Color(0xFF2D1400);
  static const Color darkSurfaceAlt = Color(0xFF3D2200);
  static const Color darkBorder = amber800;
  static const Color darkText = amber100;

  static const Color mutedText = ink700;

  // Keep legacy semantic names so existing widgets compile unchanged.
  static const Color primaryAccent = amber600;
  static const Color secondaryAccent = amber800;

  static final Color primaryAccent05 = primaryAccent.withValues(alpha: 0.05);
  static final Color primaryAccent10 = primaryAccent.withValues(alpha: 0.10);
  static final Color primaryAccent20 = primaryAccent.withValues(alpha: 0.20);
  static final Color primaryAccent30 = primaryAccent.withValues(alpha: 0.30);

  static final Color darkBase90 = darkBase.withValues(alpha: 0.90);
  static final Color darkBase50 = darkBase.withValues(alpha: 0.50);
}

class AppTheme {
  static TextTheme _simpleTextTheme({required Brightness brightness}) {
    final baseColor =
        brightness == Brightness.dark
            ? AppColors.darkText
            : AppColors.lightText;
    final variantColor =
        brightness == Brightness.dark
            ? AppColors.slate400
            : AppColors.mutedText;

    return TextTheme(
      displayLarge: GoogleFonts.bebasNeue(color: baseColor, letterSpacing: 2.2),
      headlineMedium: GoogleFonts.bebasNeue(
        color: baseColor,
        letterSpacing: 1.4,
      ),
      headlineSmall: GoogleFonts.bebasNeue(
        color: baseColor,
        letterSpacing: 1.2,
      ),
      titleLarge: GoogleFonts.bebasNeue(color: baseColor, letterSpacing: 1.0),
      titleMedium: GoogleFonts.spaceMono(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.spaceMono(color: baseColor),
      bodySmall: GoogleFonts.spaceMono(color: variantColor),
      labelMedium: GoogleFonts.spaceMono(color: variantColor),
    );
  }

  static final _lightTextButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.lightText,
    textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
    side: const BorderSide(color: AppColors.lightBorder, width: 1),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static final _darkTextButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.darkText,
    textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
    side: const BorderSide(color: AppColors.darkBorder, width: 1),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.darkText,
      onSecondary: AppColors.darkText,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.mutedText,
      outline: AppColors.lightBorder,
    );

    final textTheme = _simpleTextTheme(brightness: Brightness.light);

    return ThemeData(
      useMaterial3: false,
      fontFamily: GoogleFonts.spaceMono().fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: colorScheme,
      dividerColor: AppColors.lightBorder,
      cardColor: AppColors.lightSurface,
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightText,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: _lightTextButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightText,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.lightText,
          elevation: 0,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.lightText,
        unselectedLabelColor: AppColors.ink700,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 3),
        ),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.darkText,
      onSecondary: AppColors.darkText,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.slate400,
      outline: AppColors.darkBorder,
    );

    final textTheme = _simpleTextTheme(brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: false,
      fontFamily: GoogleFonts.spaceMono().fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      dividerColor: AppColors.darkBorder,
      cardColor: AppColors.darkSurface,
      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: _darkTextButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.darkText,
          elevation: 0,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.darkText,
        unselectedLabelColor: AppColors.amber300,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 3),
        ),
      ),
      textTheme: textTheme,
    );
  }
}
