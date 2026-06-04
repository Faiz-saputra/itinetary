import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

/// Builds the global light theme for the application using Material 3.
class AppTheme {
  AppTheme._();

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppConstants.primaryColor,
    brightness: Brightness.light,
    secondary: AppConstants.secondaryColor,
    surface: AppConstants.surfaceColor,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme(Typography.blackMountainView),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        iconTheme: IconThemeData(color: _lightColorScheme.onPrimary),
        backgroundColor: _lightColorScheme.primary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightColorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
