import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryGreen = Color(0xFF0D5C3A);
  static const Color primaryGreenLight = Color(0xFF1B7A50);
  static const Color primaryGreenDark = Color(0xFF073823);

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldAccentLight = Color(0xFFE5C158);
  static const Color goldAccentDark = Color(0xFF997A15);

  // ألوان أذكار الصباح
  static const Color morningStart = Color(0xFFE65100);
  static const Color morningEnd = Color(0xFFFFA726);
  static const Color morningCardBg = Color(0xFFFFF8E7);

  // ألوان أذكار المساء
  static const Color eveningStart = Color(0xFF1A237E);
  static const Color eveningEnd = Color(0xFF3949AB);
  static const Color eveningCardBg = Color(0xFFEEF2FF);

  // خلفيات
  static const Color lightBg = Color(0xFFF8FAF7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF0B1411);
  static const Color darkCard = Color(0xFF14241F);

  static TextStyle getArabicFont({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.6,
    FontStyle? fontStyle,
  }) {
    try {
      return GoogleFonts.amiri(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
        fontFamilyFallback: const [
          'Scheherazade New',
          'Traditional Arabic',
          'Cairo',
          'Segoe UI',
          'Tahoma',
          'Arial',
        ],
      );
    }
  }

  static TextStyle getCairoFont({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.4,
    FontStyle? fontStyle,
  }) {
    try {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Cairo',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
        fontFamilyFallback: const ['Segoe UI', 'Tahoma', 'Arial'],
      );
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightBg,
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryGreen.withValues(alpha: 0.08), width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: getArabicFont(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: goldAccent,
      surface: lightCard,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreenLight,
    scaffoldBackgroundColor: darkBg,
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: goldAccent.withValues(alpha: 0.18), width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkCard,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: getArabicFont(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreenLight,
      secondary: goldAccent,
      surface: darkCard,
    ),
  );
}
