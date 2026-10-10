import 'package:flutter/material.dart';

/// Centralized color palette for the Sessizlik app.
/// Provides consistent, theme-aware, and readable color tokens.
class AppColors {
  AppColors._();

  // Primary Pastel Palette
  static const Color primary = Color(0xFF8E9DF7);       // Soft Lavender Blue
  static const Color secondary = Color(0xFFF78EAE);     // Soft Rose Pink
  static const Color mint = Color(0xFF8EF7CD);          // Soft Mint Green
  static const Color peach = Color(0xFFF7BD8E);         // Soft Peach Orange
  static const Color purple = Color(0xFFB38EF7);        // Soft Purple
  static const Color amber = Color(0xFFFFB347);         // Party Challenge Amber

  // Dark & Light Background Tokens
  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color backgroundDark = Color(0xFF1E1E2C);
  static const Color surfaceDark = Color(0xFF111424);

  // Text Colors
  static const Color textDark = Color(0xFF2E3E5C);
  static const Color textLight = Color(0xFFECEFF1);
  static const Color textMutedDark = Color(0xFF5E6E8C);
  static const Color textMutedLight = Colors.white70;

  // Semantic & Team Aliases
  static const Color teamA = primary;
  static const Color teamB = secondary;
  static const Color rose = secondary;
  static const Color accentWarning = amber;

  // Semantic Colors
  static const Color success = Color(0xFF8EF7CD);
  static const Color warning = Color(0xFFF7BD8E);
  static const Color danger = Color(0xFFF78EAE);
  static const Color info = Color(0xFF8E9DF7);

  // Difficulty Badges
  static const Color difficultyEasy = Color(0xFF8EF7CD);
  static const Color difficultyMedium = Color(0xFFF7BD8E);
  static const Color difficultyHard = Color(0xFFF78EAE);
  static const Color difficultyExpert = Color(0xFFB38EF7);
}
