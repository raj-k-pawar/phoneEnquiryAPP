import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimary      = Color(0xFF2D6A4F);
const Color kPrimaryDark  = Color(0xFF1B4332);
const Color kPrimaryLight = Color(0xFF52B788);
const Color kAccent       = Color(0xFFD4A017);
const Color kBg           = Color(0xFFF8FBF8);
const Color kTextPrimary  = Color(0xFF1B2D1E);
const Color kTextSecondary= Color(0xFF5A7A62);
const Color kDivider      = Color(0xFFE0EDE3);
const Color kError        = Color(0xFFD32F2F);
const Color kSuccess      = Color(0xFF388E3C);
const Color kCard         = Color(0xFFFFFFFF);

final List<Color> kBatchColors = [
  const Color(0xFF2196F3),
  const Color(0xFF9C27B0),
  const Color(0xFFFF5722),
  const Color(0xFF00BCD4),
  const Color(0xFF4CAF50),
  const Color(0xFFFF9800),
];

Color batchColor(int index) => kBatchColors[index % kBatchColors.length];

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: kPrimary,
      secondary: kAccent,
      surface: kCard,
      error: kError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: kBg,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: kTextPrimary,
      displayColor: kTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F7F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kError),
      ),
      labelStyle: GoogleFonts.poppins(color: kTextSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardTheme(
      color: kCard,
      elevation: 2,
      shadowColor: kPrimary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
    ),
  );
}
