import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF74D7CF);
  static const Color secondary = Color(0xFF74D7CE);
  static const Color tertiary = Color(0xFFFFB878);
  static const Color neutral = Color(0xFF1A1C1E);
  
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1A1C1E);
  static const Color selected = Color(0xFF407671);
}

class AppFonts {
  // Titles use Space Grotesk (bundled local font, declared in pubspec.yaml).
  // Body and labels use Geist Regular. Both are real bundled families, so
  // `const TextStyle(fontFamily: ...)` resolves them reliably offline.
  static const String headline = 'Space Grotesk';
  static const String body = 'Geist';
  static const String label = 'Geist';
}
