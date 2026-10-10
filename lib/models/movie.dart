import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Difficulty level for a movie card.
enum MovieDifficulty {
  kolay,
  orta,
  zor,
  cokZor;

  /// Human-readable label with badge emoji
  String get label {
    switch (this) {
      case MovieDifficulty.kolay:
        return '⚡ Kolay';
      case MovieDifficulty.orta:
        return '⚡ Orta';
      case MovieDifficulty.zor:
        return '⚡ Zor';
      case MovieDifficulty.cokZor:
        return '⚡ Çok Zor';
    }
  }

  /// Theme-consistent badge color
  Color get color {
    switch (this) {
      case MovieDifficulty.kolay:
        return AppColors.difficultyEasy;
      case MovieDifficulty.orta:
        return AppColors.difficultyMedium;
      case MovieDifficulty.zor:
        return AppColors.difficultyHard;
      case MovieDifficulty.cokZor:
        return AppColors.difficultyExpert;
    }
  }
}

/// Domain model representing a movie or TV show card in the game.
@immutable
class Movie {
  final String title;
  final bool isYerli; // true for Turkish (Yerli), false for Foreign (Yabancı)
  final MovieDifficulty difficulty;
  final String? posterUrl;

  const Movie({
    required this.title,
    required this.isYerli,
    required this.difficulty,
    this.posterUrl,
  });

  /// True if movie is foreign language
  bool get isForeign => !isYerli;

  /// Origin label with flag
  String get originBadge => isYerli ? '🇹🇷 Yerli' : '🌍 Yabancı';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie &&
          runtimeType == other.runtimeType &&
          title.toLowerCase() == other.title.toLowerCase() &&
          isYerli == other.isYerli;

  @override
  int get hashCode => title.toLowerCase().hashCode ^ isYerli.hashCode;

  @override
  String toString() => 'Movie(title: $title, isYerli: $isYerli, difficulty: $difficulty)';
}
