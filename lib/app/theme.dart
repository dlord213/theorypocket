import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    if (state == ThemeMode.system) {
      // If system is dark, switch to light, else dark
      // For simplicity, cycle to dark first if currently system
      state = ThemeMode.dark;
    } else {
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AppTheme {
  static const primaryLime = Color(0xFFA3E635);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLime,
      brightness: Brightness.light,
      surface: const Color(0xFFF8FAFC),
      onSurface: const Color(0xFF0F172A),
      surfaceContainer: const Color(0xFFF1F5F9),
      surfaceContainerHigh: const Color(0xFFE2E8F0),
      primary: const Color(0xFF65A30D),
      onPrimary: Colors.white,
      secondary: const Color(0xFF059669),
      tertiary: const Color(0xFF0D9488),
      outline: const Color(0xFFCBD5E1),
    );
    return _build(base, colorScheme);
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLime,
      brightness: Brightness.dark,
      surface: const Color(0xFF000000), // AMOLED Black
      onSurface: const Color(0xFFF8FAFC),
      surfaceContainer: const Color(0xFF0F172A),
      surfaceContainerHigh: const Color(0xFF1E293B),
      primary: primaryLime,
      onPrimary: Colors.black,
      secondary: const Color(0xFF34D399),
      tertiary: const Color(0xFF2DD4BF),
      outline: const Color(0xFF334155),
    );
    return _build(base, colorScheme);
  }

  static ThemeData _build(ThemeData base, ColorScheme colorScheme) {
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 28, // OneUI typically has larger, bolder headers
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Modern M3 / OneUI massive curves
          side: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.5),
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      textTheme: _buildTextTheme(base.textTheme, colorScheme),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    return base.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
        letterSpacing: 1.2,
      ),
    );
  }
}

