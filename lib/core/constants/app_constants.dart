import 'package:flutter/material.dart';

/// Global application constants for route names, colors, text, and timing.
class AppConstants {
  AppConstants._();

  static const String appName = 'Itinetary';
  static const String appTagline = 'Travel planner profesional.';
  static const String splashTitle = 'Itinetary';
  static const String splashSubtitle = 'Dream. Plan. Explore.';

  static const Duration splashDuration = Duration(milliseconds: 2000);
  static const double defaultPadding = 16.0;
  static const double cardRadius = 24.0;

  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF81D4FA);
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF7F9FF);
}
