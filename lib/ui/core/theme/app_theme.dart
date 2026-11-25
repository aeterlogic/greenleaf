import 'package:material_ui/material_ui.dart';

/// Green, white, and soft yellow botanical theme for GreenLeaf.
class GreenLeafColors {
  const GreenLeafColors._();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color freshGreen = Color(0xFF43A047);
  static const Color mintTint = Color(0xFFEAF6EC);
  static const Color softGreenBorder = Color(0xFFD2E8D5);

  static const Color softYellow = Color(0xFFFFF4BD);
  static const Color warmYellow = Color(0xFFF6D55C);
  static const Color softYellowTint = Color(0xFFFFFBE6);
  static const Color yellowAccentText = Color(0xFF7A5B00);

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color appBackground = Color(0xFFF8FBF7);
  static const Color textPrimary = Color(0xFF1B3524);
  static const Color textSecondary = Color(0xFF5A7061);

  static const Color desktopBackdrop = Color(0xFFE6E9E7);
  static const Color phoneBezel = Color(0xFF1B1E1C);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GreenLeafColors.primaryGreen,
      primary: GreenLeafColors.primaryGreen,
      onPrimary: GreenLeafColors.pureWhite,
      secondary: GreenLeafColors.warmYellow,
      onSecondary: GreenLeafColors.textPrimary,
      surface: GreenLeafColors.pureWhite,
      onSurface: GreenLeafColors.textPrimary,
      surfaceContainerHighest: GreenLeafColors.mintTint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GreenLeafColors.appBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: GreenLeafColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: GreenLeafColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: GreenLeafColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: GreenLeafColors.softGreenBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GreenLeafColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GreenLeafColors.softGreenBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GreenLeafColors.softGreenBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: GreenLeafColors.primaryGreen,
            width: 1.8,
          ),
        ),
        labelStyle: const TextStyle(color: GreenLeafColors.textSecondary),
        hintStyle: const TextStyle(color: Color(0xFF93A699)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GreenLeafColors.primaryGreen,
          foregroundColor: GreenLeafColors.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GreenLeafColors.primaryGreen,
        contentTextStyle: const TextStyle(
          color: GreenLeafColors.pureWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
