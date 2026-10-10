import 'package:flutter/foundation.dart';

/// Supported game modes.
enum GameMode {
  teams,
  individual;

  String get label => this == GameMode.teams ? 'Takımlı' : 'Herkes Tek';
}

/// Category filter options for movie cards.
enum MovieCategory {
  yerli,
  yabanci,
  karisik,
  ozel;

  String get label {
    switch (this) {
      case MovieCategory.yerli:
        return '🇹🇷 Yerli';
      case MovieCategory.yabanci:
        return '🌍 Yabancı';
      case MovieCategory.karisik:
        return '🔀 Karışık';
      case MovieCategory.ozel:
        return '⭐ Özel';
    }
  }
}

/// Win criteria options.
enum WinCondition {
  score,
  rounds;

  String get label => this == WinCondition.score ? 'Hedef Skor' : 'Raund Sınırı';
}

/// Difficulty filter options for game setup.
enum DifficultySelection {
  kolay,
  orta,
  zor,
  cokZor,
  hepsi;

  String get label {
    switch (this) {
      case DifficultySelection.hepsi:
        return '🌟 Hepsi';
      case DifficultySelection.kolay:
        return '🟢 Kolay';
      case DifficultySelection.orta:
        return '🟡 Orta';
      case DifficultySelection.zor:
        return '🔴 Zor';
      case DifficultySelection.cokZor:
        return '💀 Çok Zor';
    }
  }
}

/// Immutable configuration data class for a game session.
@immutable
class GameConfig {
  final GameMode gameMode;
  final List<String> players;
  final List<String> teams;
  final int duration; // in seconds (e.g. 60, 90, 120)
  final int passLimit; // e.g. 2, 3
  final MovieCategory category;
  final WinCondition winCondition;
  final int targetScore; // e.g. 5, 10
  final int rounds; // e.g. 3, 5
  final DifficultySelection difficultySelection;
  final Map<String, String>? playerToTeam;
  final bool enablePartyChallenges;

  const GameConfig({
    required this.gameMode,
    required this.players,
    required this.teams,
    required this.duration,
    required this.passLimit,
    required this.category,
    required this.winCondition,
    required this.targetScore,
    required this.rounds,
    required this.difficultySelection,
    this.playerToTeam,
    this.enablePartyChallenges = false,
  });

  /// Factory for standard quick-start configuration
  factory GameConfig.quickPlay({
    List<String> players = const ['1. Oyuncu', '2. Oyuncu'],
    int duration = 60,
  }) {
    return GameConfig(
      gameMode: GameMode.individual,
      players: players,
      teams: const ['A Takımı', 'B Takımı'],
      duration: duration,
      passLimit: 2,
      category: MovieCategory.karisik,
      winCondition: WinCondition.score,
      targetScore: 5,
      rounds: 3,
      difficultySelection: DifficultySelection.hepsi,
      playerToTeam: null,
      enablePartyChallenges: false,
    );
  }

  /// Default initial configuration for SetupScreen
  factory GameConfig.defaultConfig() {
    return const GameConfig(
      gameMode: GameMode.individual,
      players: [],
      teams: ['A Takımı', 'B Takımı'],
      duration: 60,
      passLimit: 2,
      category: MovieCategory.karisik,
      winCondition: WinCondition.score,
      targetScore: 5,
      rounds: 3,
      difficultySelection: DifficultySelection.hepsi,
      playerToTeam: null,
      enablePartyChallenges: false,
    );
  }

  /// Creates a copy with optional parameter overrides
  GameConfig copyWith({
    GameMode? gameMode,
    List<String>? players,
    List<String>? teams,
    int? duration,
    int? passLimit,
    MovieCategory? category,
    WinCondition? winCondition,
    int? targetScore,
    int? rounds,
    DifficultySelection? difficultySelection,
    Map<String, String>? playerToTeam,
    bool? enablePartyChallenges,
  }) {
    return GameConfig(
      gameMode: gameMode ?? this.gameMode,
      players: players ?? this.players,
      teams: teams ?? this.teams,
      duration: duration ?? this.duration,
      passLimit: passLimit ?? this.passLimit,
      category: category ?? this.category,
      winCondition: winCondition ?? this.winCondition,
      targetScore: targetScore ?? this.targetScore,
      rounds: rounds ?? this.rounds,
      difficultySelection: difficultySelection ?? this.difficultySelection,
      playerToTeam: playerToTeam ?? this.playerToTeam,
      enablePartyChallenges: enablePartyChallenges ?? this.enablePartyChallenges,
    );
  }
}
