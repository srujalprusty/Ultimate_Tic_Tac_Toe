import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color background     = Color(0xFF0D1117);
  static const Color surface        = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF21262D);
  static const Color border         = Color(0xFF30363D);
  static const Color textPrimary    = Color(0xFFE6EDF3);
  static const Color textSecondary  = Color(0xFF8B949E);

  // Game colours
  static const Color xColor      = Color(0xFF58A6FF); // blue  – Player X
  static const Color oColor      = Color(0xFFFF7B72); // red   – Player O
  static const Color activeBoard = Color(0xFF3FB950); // green – highlighted board
  static const Color primary     = Color(0xFF58A6FF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        onPrimary: Colors.black,
        secondary: oColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
