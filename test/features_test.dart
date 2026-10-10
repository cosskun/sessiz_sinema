import 'package:flutter_test/flutter_test.dart';
import 'package:sessizlik/models/custom_movie_manager.dart';
import 'package:sessizlik/models/game_config.dart';
import 'package:sessizlik/models/game_state.dart';
import 'package:sessizlik/models/movie.dart';
import 'package:sessizlik/models/party_challenge.dart';
import 'package:sessizlik/models/sound_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Yeni Özellikler Testleri', () {
    test('1. SoundManager sessize alma ve açma sorunsuz çalışmalı', () {
      final sound = SoundManager.instance;
      expect(sound.isSoundEnabled, true);
      sound.toggleSound();
      expect(sound.isSoundEnabled, false);
      sound.toggleSound();
      expect(sound.isSoundEnabled, true);

      // Metotlar hata fırlatmadan çalışmalı
      sound.playTick();
      sound.playSuccess();
      sound.playPass();
      sound.playTimeOut();
      sound.playCelebration();
    });

    test('2. PartyChallenge rastgele handikap kuralı üretebilmeli', () {
      final challenge = PartyChallenge.getRandom();
      expect(challenge.title.isNotEmpty, true);
      expect(challenge.icon.isNotEmpty, true);
      expect(PartyChallenge.allChallenges.length, greaterThanOrEqualTo(10));
    });

    test('3. CustomMovieManager film ekleme, silme ve listeleme', () {
      final manager = CustomMovieManager.instance;
      final initialCount = manager.movies.length;

      final added = manager.addMovie('Bize Özel Test Filmi', isYerli: true, difficulty: MovieDifficulty.orta);
      expect(added, true);
      expect(manager.movies.length, initialCount + 1);
      expect(manager.movies.any((m) => m.title == 'Bize Özel Test Filmi'), true);

      manager.removeMovie(0);
      expect(manager.movies.length, initialCount);
    });

    test('4. MVP ve Gecenin Yıldızları İstatistikleri doğru hesaplanmalı', () {
      final config = GameConfig(
        gameMode: GameMode.individual,
        players: ['Ali', 'Ayşe'],
        teams: ['A Takımı', 'B Takımı'],
        duration: 60,
        passLimit: 5,
        category: MovieCategory.karisik,
        winCondition: WinCondition.score,
        targetScore: 10,
        rounds: 5,
        difficultySelection: DifficultySelection.hepsi,
      );

      final state = GameState(config: config);

      // Ali 10 saniyede bilirse
      state.startTurn();
      state.timerSeconds = 50; // 10 saniye harcandı (60 - 50 = 10s)
      state.scorePoint();

      expect(state.fastestPlayer?.key, 'Ali');
      expect(state.fastestPlayer?.value, 10);
      expect(state.streakChampion?.key, 'Ali');
      expect(state.streakChampion?.value, 1);

      // Ayşe pas geçiyor
      state.startTurn();
      state.passMovie();
      expect(state.passChampion?.key, 'Ayşe');
      expect(state.passChampion?.value, 1);
    });
  });
}
