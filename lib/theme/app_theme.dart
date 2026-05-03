import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceVariant = Color(0xFF1A1A26);
  static const Color card = Color(0xFF1A1A26);
  static const Color cardElevated = Color(0xFF222230);
  
  static const Color accent = Color(0xFFE50914); // Netflix Red
  static const Color accentVariant = Color(0xFFB20710);
  static const Color gold = Color(0xFFF5C518); // IMDb Gold for ratings
  static const Color success = Color(0xFF4CAF50);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF737373);

  static const Color border = Color(0xFF2A2A35);
  static const Color divider = Color(0xFF1F1F2A);

  static const Color shimmerBase = Color(0xFF12121A);
  static const Color shimmerHighlight = Color(0xFF1A1A26);

  static const Map<String, Color> genreColors = {
    'Action': Color(0xFFE50914),
    'Aventure': Color(0xFFF5C518),
    'Animation': Color(0xFF2196F3),
    'Comédie': Color(0xFFFF9800),
    'Crime': Color(0xFF9C27B0),
    'Documentaire': Color(0xFF4CAF50),
    'Drame': Color(0xFF795548),
    'Familial': Color(0xFFE91E63),
    'Fantastique': Color(0xFF673AB7),
    'Histoire': Color(0xFF607D8B),
    'Horreur': Color(0xFF000000),
    'Musique': Color(0xFFFFEB3B),
    'Mystère': Color(0xFF3F51B5),
    'Romance': Color(0xFFFF4081),
    'Science-Fiction': Color(0xFF00BCD4),
    'Téléfilm': Color(0xFF9E9E9E),
    'Thriller': Color(0xFFFF5722),
    'Guerre': Color(0xFF455A64),
    'Western': Color(0xFF8D6E63),
  };
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;

  static BorderRadius card = BorderRadius.circular(md);
  static BorderRadius button = BorderRadius.circular(sm);
  static BorderRadius chip = BorderRadius.circular(full);
  static BorderRadius sheet = const BorderRadius.vertical(top: Radius.circular(xl));
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(seconds: 2);
  
  static const Curve cubicBezier = Cubic(0.22, 1, 0.36, 1);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.dmSansTextTheme();
    final displayFont = GoogleFonts.bebasNeue();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentVariant,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: displayFont.copyWith(
          color: AppColors.textPrimary,
          fontSize: 42,
          letterSpacing: 1.2,
        ),
        displayMedium: displayFont.copyWith(
          color: AppColors.textPrimary,
          fontSize: 34,
          letterSpacing: 1.0,
        ),
        displaySmall: displayFont.copyWith(
          color: AppColors.textPrimary,
          fontSize: 28,
          letterSpacing: 0.8,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: displayFont.copyWith(
          color: AppColors.textPrimary,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent,
        labelStyle: GoogleFonts.dmSans(fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
