import 'package:flutter/material.dart';

class AppColors {
  // Mkeka Plus teal color system.
  static const Color primaryDark = Color(0xFF004D56);
  static const Color mediumTeal = Color(0xFF00606B);
  static const Color lightTeal = Color(0xFFE6F0F1);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color softBlue = Color(0xFF00A3AD);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkTextGrey = Color(0xFF333333);
  static const Color lightTextGrey = Color(0xFF757575);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = lightTeal;
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD8E5E7);

  static const Color primary = primaryDark;
  static const Color secondary = mediumTeal;
  static const Color accent = accentOrange;

  static const Color textPrimary = darkTextGrey;
  static const Color textSecondary = lightTextGrey;
  static const Color textHint = Color(0xFF9AA4A6);

  static const Color won = mediumTeal;
  static const Color lost = Color(0xFFA32D2D);
  static const Color void_ = Color(0xFF737987);
  static const Color pending = accentOrange;
  static const Color pendingSurface = Color(0xFFFFF3E0);
  static const Color vipGold = accentOrange;
  static const Color vipGoldDark = Color(0xFFE07F00);

  // Backward-compatible aliases for older widgets in the app.
  static const Color neutralLight = lightGrey;
  static const Color neutralMid = lightTextGrey;
  static const Color neutralDeep = darkTextGrey;
  static const Color lightPurple = lightTeal;
  static const Color midPurple = mediumTeal;
  static const Color deepPurple = primaryDark;
  static const Color neonGreen = primaryDark;
  static const Color neonGreenDark = mediumTeal;
}

class AppTheme {
  static ThemeData get dark {
    return light;
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.lost,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lost),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      dividerColor: AppColors.border,
    );
  }
}
