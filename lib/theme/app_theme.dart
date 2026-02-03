import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color secondary = Color(0xFF64748B); // Slate
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Background & Surface
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color bibleBackgroundCream = Color(0xFFFEFCE8);

  // Text Colors
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color primaryTextDark = Color(0xFFF8FAFC);
  static const Color secondaryTextDark = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.notoSansKrTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        titleLarge: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF64748B),
        ),
        labelLarge: GoogleFonts.notoSansKr(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.surfaceWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.primaryTextDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: GoogleFonts.notoSansKrTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextDark,
            ),
            titleLarge: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextDark,
            ),
            bodyLarge: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryTextDark,
            ),
            bodyMedium: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.secondaryTextDark,
            ),
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.surfaceDark,
      ),
    );
  }

  // Helper for Bible text (Serif)
  static TextStyle get bibleTextStyle {
    return GoogleFonts.nanumMyeongjo(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      height: 1.6,
      color: AppColors.textMain,
    );
  }

  // Shadow Styles
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get indigoShadow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
}
