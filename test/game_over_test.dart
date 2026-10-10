import 'package:flutter_test/flutter_test.dart';
import 'package:sessizlik/models/game_config.dart';
import 'package:sessizlik/models/game_state.dart';
import 'package:sessizlik/models/movie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Oyun Sonu (Game Over) Testleri', () {
    test('Bireysel modda hedef skora ulaşıldığında oyun başarıyla sonlanmalı ve kazanan belirlenmeli', () {
      final config = GameConfig(
        gameMode: GameMode.individual,
        players: ['Ahmet', 'Mehmet'],
        teams: ['A Takımı', 'B Takımı'],
        duration: 60,
        passLimit: 2,
        category: MovieCategory.karisik,
        winCondition: WinCondition.score,
        targetScore: 2,
        rounds: 3,
        difficultySelection: DifficultySelection.hepsi,
      );

      final state = GameState(config: config);

      expect(state.isGameOver, false);
      expect(state.winnerName, null);

      // Ahmet 1 puan alıyor
      state.scorePoint();
      expect(state.isGameOver, false);
      expect(state.scores['Ahmet'], 1);

      // Mehmet pas geçiyor / bilemiyor
      state.failTurn();
      expect(state.isGameOver, false);
      expect(state.scores['Mehmet'], 0);

      // Ahmet 2. puanı alıyor (hedef skora ulaşıyor)
      state.scorePoint();
      expect(state.isGameOver, true);
      expect(state.winnerName, 'Ahmet');
    });

    test('Takımlı modda hedef skora ulaşıldığında kazanan takım doğru belirlenmeli', () {
      final config = GameConfig(
        gameMode: GameMode.teams,
        players: ['Ahmet', 'Elif'],
        teams: ['A Takımı', 'B Takımı'],
        duration: 60,
        passLimit: 2,
        category: MovieCategory.karisik,
        winCondition: WinCondition.score,
        targetScore: 1,
        rounds: 3,
        difficultySelection: DifficultySelection.hepsi,
        playerToTeam: {'Ahmet': 'A Takımı', 'Elif': 'B Takımı'},
      );

      final state = GameState(config: config);

      expect(state.isGameOver, false);

      // Ahmet (A Takımı) bilince A Takımı 1 puana ulaşıp kazanmalı
      state.scorePoint();
      expect(state.isGameOver, true);
      expect(state.winnerName, 'A Takımı');
      expect(state.scores['A Takımı'], 1);
    });
  });
}
