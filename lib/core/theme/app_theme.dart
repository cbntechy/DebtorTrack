import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D2C8D)),
    useMaterial3: true,
    textTheme: ThemeData.light().textTheme
        .apply(fontFamily: GoogleFonts.manrope().fontFamily),
  );
}
