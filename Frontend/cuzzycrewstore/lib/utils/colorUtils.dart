import 'package:flutter/material.dart';
// not fixed: we can change this acc to figma actual color codes(freestyle way) when we start

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class AppColors {
  static const Color primaryAccent = Color(0xFFE39C3A);
  static const Color secondaryAccent = Color(0xFFA16E29);

  static const Color slate50 = Color(0xFFF1F5F9);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);

  static const Color darkBase = Color(0xFF211A11);

  static const Color lightBackground = Color(0xFFF0F0F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE4E4E4);
  static const Color lightBorder = Color(0xFFCCCCCC);
  static const Color lightText = Color(0xFF1A1A1A);

  static const Color darkBackground = Color(0xFF211A11);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceAlt = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFE8E8E8);

  static const Color mutedText = Color(0xFF666666);

  static final Color primaryAccent05 = primaryAccent.withValues(alpha: 0.05);
  static final Color primaryAccent10 = primaryAccent.withValues(alpha: 0.10);
  static final Color primaryAccent20 = primaryAccent.withValues(alpha: 0.20);
  static final Color primaryAccent30 = primaryAccent.withValues(alpha: 0.30);

  static final Color darkBase90 = darkBase.withValues(alpha: 0.90);
  static final Color darkBase50 = darkBase.withValues(alpha: 0.50);
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.darkText,
      onSecondary: AppColors.darkText,
      onSurface: AppColors.lightText,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: colorScheme,
      dividerColor: AppColors.lightBorder,
      cardColor: AppColors.lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        bodySmall: TextStyle(color: AppColors.mutedText),
        titleLarge: TextStyle(color: AppColors.lightText),
        titleMedium: TextStyle(color: AppColors.lightText),
        titleSmall: TextStyle(color: AppColors.lightText),
      ),
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
      outline: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      dividerColor: AppColors.darkBorder,
      cardColor: AppColors.darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        bodySmall: TextStyle(color: AppColors.mutedText),
        titleLarge: TextStyle(color: AppColors.darkText),
        titleMedium: TextStyle(color: AppColors.darkText),
        titleSmall: TextStyle(color: AppColors.darkText),
      ),
    );
  }
}
