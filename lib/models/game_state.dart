import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/movie_list.dart';
import '../services/sound_service.dart';
import 'custom_movie_manager.dart';
import 'game_config.dart';
import 'movie.dart';
import 'party_challenge.dart';

/// Central state manager and controller for an active game session.
class GameState extends ChangeNotifier {
  final GameConfig config;

  // Scores: Player -> points (Individual) or Team -> points (Teams)
  final Map<String, int> scores = {};

  // Player to Team mapping (Player Name -> Team Name)
  final Map<String, String> playerTeams = {};

  // MVP & Performance Statistics
  final Map<String, int> quickestGuesses = {}; // entity -> fastest guess in seconds
  final Map<String, int> passCounts = {};     // entity -> total passes
  final Map<String, int> currentStreaks = {};
  final Map<String, int> maxStreaks = {};      // entity -> max consecutive points

  List<Movie> _playlist = [];
  int _playlistIndex = 0;

  int currentPlayerIndex = 0;
  int currentRound = 1;

  int remainingPasses = 0;
  bool isTurnRunning = false;
  bool isTurnPaused = false;
  int timerSeconds = 0;
  bool isGameOver = false;
  String? winnerName;

  PartyChallenge? currentChallenge;
  Timer? _timer;

  // Card visibility toggle
  bool isMovieRevealed = false;

  GameState({required this.config}) {
    _initializeGame();
  }

  MovieDifficulty _mapSelectionToMovieDifficulty(DifficultySelection selection) {
    switch (selection) {
      case DifficultySelection.kolay:
        return MovieDifficulty.kolay;
      case DifficultySelection.orta:
        return MovieDifficulty.orta;
      case DifficultySelection.zor:
        return MovieDifficulty.zor;
      case DifficultySelection.cokZor:
        return MovieDifficulty.cokZor;
      case DifficultySelection.hepsi:
        return MovieDifficulty.orta;
    }
  }

  void _initializeGame() {
    scores.clear();
    quickestGuesses.clear();
    passCounts.clear();
    currentStreaks.clear();
    maxStreaks.clear();
    playerTeams.clear();

    if (config.gameMode == GameMode.individual) {
      for (final player in config.players) {
        scores[player] = 0;
        quickestGuesses[player] = 999;
        passCounts[player] = 0;
        currentStreaks[player] = 0;
        maxStreaks[player] = 0;
      }
    } else {
      for (final team in config.teams) {
        scores[team] = 0;
        quickestGuesses[team] = 999;
        passCounts[team] = 0;
        currentStreaks[team] = 0;
        maxStreaks[team] = 0;
      }

      if (config.playerToTeam != null) {
        playerTeams.addAll(config.playerToTeam!);
      } else if (config.players.isNotEmpty) {
        for (int i = 0; i < config.players.length; i++) {
          final team = config.teams[i % config.teams.length];
          playerTeams[config.players[i]] = team;
        }
      }
    }

    _setupPlaylist();

    currentPlayerIndex = 0;
    currentRound = 1;
    remainingPasses = config.passLimit;
    timerSeconds = config.duration;
    isGameOver = false;
    winnerName = null;
    isMovieRevealed = false;

    if (config.enablePartyChallenges) {
      currentChallenge = PartyChallenge.getRandom();
    } else {
      currentChallenge = null;
    }
  }

  void _setupPlaylist() {
    if (config.category == MovieCategory.ozel) {
      _playlist = List.from(CustomMovieManager.instance.movies);
      if (_playlist.isEmpty) {
        _playlist = List.from(MovieDatabase.movies);
      }
    } else {
      _playlist = MovieDatabase.movies.where((movie) {
        // 1. Language Filter
        final matchesLanguage = config.category == MovieCategory.karisik ||
            (config.category == MovieCategory.yerli && movie.isYerli) ||
            (config.category == MovieCategory.yabanci && !movie.isYerli);

        if (!matchesLanguage) return false;

        // 2. Difficulty Filter
        if (config.difficultySelection == DifficultySelection.hepsi) return true;
        final targetDiff = _mapSelectionToMovieDifficulty(config.difficultySelection);
        return movie.difficulty == targetDiff;
      }).toList();
    }

    // Fallback if playlist is empty
    if (_playlist.isEmpty) {
      _playlist = MovieDatabase.movies.where((movie) {
        if (config.category == MovieCategory.yerli) return movie.isYerli;
        if (config.category == MovieCategory.yabanci) return !movie.isYerli;
        return true;
      }).toList();
    }

    _playlist.shuffle(Random());
    _playlistIndex = 0;
  }

  /// Current movie card to be acted out
  Movie get currentMovie {
    if (_playlist.isEmpty) {
      return const Movie(title: 'Film Bulunamadı', isYerli: true, difficulty: MovieDifficulty.orta);
    }
    return _playlist[_playlistIndex % _playlist.length];
  }

  /// Active actor/player name
  String get activePlayerName {
    if (config.players.isEmpty) return 'Bilinmeyen Oyuncu';
    return config.players[currentPlayerIndex];
  }

  /// Active player's team name (if in team mode)
  String? get activePlayerTeam {
    if (config.gameMode == GameMode.individual) return null;
    return playerTeams[activePlayerName];
  }

  /// Entity name earning scores (Player Name or Team Name)
  String get activeEntityName {
    if (config.gameMode == GameMode.individual) {
      return activePlayerName;
    }
    return activePlayerTeam ?? (config.teams.isNotEmpty ? config.teams[0] : 'A Takımı');
  }

  /// Starts turn countdown timer
  void startTurn() {
    isTurnRunning = true;
    isTurnPaused = false;
    isMovieRevealed = false;
    remainingPasses = config.passLimit;
    timerSeconds = config.duration;

    if (config.enablePartyChallenges) {
      currentChallenge = PartyChallenge.getRandom();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        timerSeconds--;
        if (timerSeconds <= 10 && timerSeconds > 0) {
          SoundService.instance.playTick();
        }
        notifyListeners();
      } else {
        timeOut();
      }
    });
    notifyListeners();
  }

  /// Pauses the active turn
  void pauseTurn() {
    if (isTurnRunning && !isTurnPaused) {
      isTurnPaused = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  /// Resumes the paused turn
  void resumeTurn() {
    if (isTurnRunning && isTurnPaused) {
      isTurnPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timerSeconds > 0) {
          timerSeconds--;
          if (timerSeconds <= 10 && timerSeconds > 0) {
            SoundService.instance.playTick();
          }
          notifyListeners();
        } else {
          timeOut();
        }
      });
      notifyListeners();
    }
  }

  /// Toggles visibility of the current movie card
  void toggleMovieReveal() {
    isMovieRevealed = !isMovieRevealed;
    notifyListeners();
  }

  /// Records a successful guess (Point scored)
  void scorePoint() {
    _timer?.cancel();
    isTurnRunning = false;

    final entity = activeEntityName;
    scores[entity] = (scores[entity] ?? 0) + 1;

    // Track MVP Stats
    final elapsed = config.duration - timerSeconds;
    if (elapsed > 0 && elapsed < (quickestGuesses[entity] ?? 999)) {
      quickestGuesses[entity] = elapsed;
    }
    currentStreaks[entity] = (currentStreaks[entity] ?? 0) + 1;
    if (currentStreaks[entity]! > (maxStreaks[entity] ?? 0)) {
      maxStreaks[entity] = currentStreaks[entity]!;
    }

    SoundService.instance.playSuccess();

    _checkWinConditions();
    if (!isGameOver) {
      _nextPlayer();
    }
    notifyListeners();
  }

  /// Records turn failure / time out
  void failTurn() {
    _timer?.cancel();
    isTurnRunning = false;

    final entity = activeEntityName;
    currentStreaks[entity] = 0;

    SoundService.instance.playTimeOut();

    _nextPlayer();
    notifyListeners();
  }

  /// Called automatically when timer reaches zero
  void timeOut() {
    _timer?.cancel();
    isTurnRunning = false;

    final entity = activeEntityName;
    currentStreaks[entity] = 0;

    SoundService.instance.playTimeOut();

    _nextPlayer();
    notifyListeners();
  }

  /// Passes the current movie and draws the next
  void passMovie() {
    if (remainingPasses > 0) {
      remainingPasses--;
      _playlistIndex++;
      timerSeconds = config.duration;
      isMovieRevealed = false;

      final entity = activeEntityName;
      passCounts[entity] = (passCounts[entity] ?? 0) + 1;
      currentStreaks[entity] = 0;

      if (config.enablePartyChallenges) {
        currentChallenge = PartyChallenge.getRandom();
      }

      SoundService.instance.playPass();
      notifyListeners();
    }
  }

  void _nextPlayer() {
    _playlistIndex++;
    isMovieRevealed = false;

    if (config.players.isEmpty) return;

    currentPlayerIndex++;

    if (currentPlayerIndex >= config.players.length) {
      currentPlayerIndex = 0;
      currentRound++;

      if (config.winCondition == WinCondition.rounds && currentRound > config.rounds) {
        _endGame();
        return;
      }
    }

    if (config.enablePartyChallenges) {
      currentChallenge = PartyChallenge.getRandom();
    }
  }

  void _checkWinConditions() {
    if (config.winCondition == WinCondition.score) {
      scores.forEach((entity, score) {
        if (score >= config.targetScore) {
          isGameOver = true;
          winnerName = entity;
          SoundService.instance.playCelebration();
        }
      });
    }
  }

  void _endGame() {
    isGameOver = true;
    _timer?.cancel();

    int maxScore = -1;
    String topEntity = 'Bilinmeyen';
    bool isTie = false;

    scores.forEach((entity, score) {
      if (score > maxScore) {
        maxScore = score;
        topEntity = entity;
        isTie = false;
      } else if (score == maxScore) {
        isTie = true;
      }
    });

    if (isTie) {
      winnerName = 'Berabere! (Dostluk Kazandı)';
    } else {
      winnerName = topEntity;
    }
    SoundService.instance.playCelebration();
  }

  // MVP Statistics Getters
  MapEntry<String, int>? get fastestPlayer {
    final valid = quickestGuesses.entries.where((e) => e.value < 999).toList();
    if (valid.isEmpty) return null;
    valid.sort((a, b) => a.value.compareTo(b.value));
    return valid.first;
  }

  MapEntry<String, int>? get streakChampion {
    final valid = maxStreaks.entries.where((e) => e.value >= 1).toList();
    if (valid.isEmpty) return null;
    valid.sort((a, b) => b.value.compareTo(a.value));
    return valid.first;
  }

  MapEntry<String, int>? get passChampion {
    final valid = passCounts.entries.where((e) => e.value > 0).toList();
    if (valid.isEmpty) return null;
    valid.sort((a, b) => b.value.compareTo(a.value));
    return valid.first;
  }

  /// Resets the game to initial state
  void resetGame() {
    _initializeGame();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
