import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sessizlik/main.dart';
import 'package:sessizlik/models/game_config.dart';
import 'package:sessizlik/models/game_state.dart';
import 'package:sessizlik/screens/custom_movies_screen.dart';
import 'package:sessizlik/screens/game_screen.dart';
import 'package:sessizlik/screens/home_screen.dart';
import 'package:sessizlik/screens/scoreboard_screen.dart';
import 'package:sessizlik/screens/setup_screen.dart';
import 'package:sessizlik/widgets/fireworks_celebration.dart';

Future<void> pumpFrames(WidgetTester tester, [int count = 5]) async {
  for (int i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kapsamlı Ekran ve Responsive UI Testleri (Android & iOS)', () {
    // 1. HomeScreen - Responsive & Button Interactions
    testWidgets('1. HomeScreen - Tüm butonlar, temalar, diyaloglar ve responsive yapı', (tester) async {
      // 1a: Standard Android screen (412 x 915)
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const SessizlikApp());
      await pumpFrames(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Sessizlik'), findsOneWidget);
      expect(find.text('⚡ Hızlı Başla (60 sn)'), findsOneWidget);
      expect(find.text('Oyunu Özelleştir & Kur'), findsOneWidget);

      // Dark Mode toggle
      final darkToggle = find.byTooltip('Karanlık Mod');
      expect(darkToggle, findsOneWidget);
      await tester.tap(darkToggle);
      await pumpFrames(tester);

      // Light Mode toggle
      final lightToggle = find.byTooltip('Aydınlık Mod');
      expect(lightToggle, findsOneWidget);
      await tester.tap(lightToggle);
      await pumpFrames(tester);

      // Sound toggle
      final soundToggle = find.byTooltip('Sesi Kapat');
      expect(soundToggle, findsOneWidget);
      await tester.tap(soundToggle);
      await pumpFrames(tester);
      expect(find.byTooltip('Sesi Aç'), findsOneWidget);
      await tester.tap(find.byTooltip('Sesi Aç'));
      await pumpFrames(tester);

      // "Nasıl Oynanır?" Dialog
      final howToPlayBtn = find.text('❓ Kurallar');
      expect(howToPlayBtn, findsOneWidget);
      await tester.tap(howToPlayBtn);
      await pumpFrames(tester);
      expect(find.text('🎭 Nasıl Oynanır?'), findsAtLeastNWidgets(1));
      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await pumpFrames(tester);

      // "Tema Değiştir" Dialog
      final themeBtn = find.byTooltip('Tema Değiştir');
      await tester.tap(themeBtn);
      await pumpFrames(tester);
      expect(find.text('🎨 Tema Seçimi'), findsOneWidget);
      await tester.tap(find.text('Cinema (Klasik Sinema)'));
      await pumpFrames(tester);

      // 1b: Small iPhone SE screen (375 x 667)
      tester.view.physicalSize = const Size(375, 667);
      await pumpFrames(tester);

      // 1c: Compact Android screen (360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      await pumpFrames(tester);

      expect(tester.takeException(), isNull, reason: 'HomeScreen hiçbir boyutta overflow vermemeli');
    });

    // 2. SetupScreen - Individual & Teams, all controls and small viewport
    testWidgets('2. SetupScreen - Bireysel & Takımlı mod, parametreler ve sıfır overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640); // Test on challenging compact size
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SetupScreen(),
        ),
      );
      await pumpFrames(tester);

      expect(find.byType(SetupScreen), findsOneWidget);
      expect(find.text('Oyun Ayarları'), findsOneWidget);

      // Add player
      final playerInput = find.widgetWithText(TextField, 'Oyuncu adı yazın...');
      expect(playerInput, findsOneWidget);
      await tester.enterText(playerInput, 'Can');
      await tester.tap(find.byIcon(Icons.add));
      await pumpFrames(tester);
      expect(find.text('Can', skipOffstage: false), findsOneWidget);

      // Switch to "Takımlı"
      await tester.tap(find.text('Takımlı'));
      await pumpFrames(tester);
      expect(find.text('👥 Takım İsimleri'), findsOneWidget);

      // Change team name
      final teamAField = find.widgetWithText(TextField, '1. Takım İsmi (Örn: A Takımı)');
      await tester.enterText(teamAField, 'Aslanlar');
      await pumpFrames(tester);
      expect(find.text('Aslanlar'), findsAtLeastNWidgets(1));

      // Scroll down
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -350));
      await pumpFrames(tester);

      // Select Pass Limit
      await tester.tap(find.text('3'));
      await pumpFrames(tester);

      // Select Category
      await tester.tap(find.text('🇹🇷 Yerli'));
      await pumpFrames(tester);

      // Select Difficulty
      await tester.tap(find.text('🟡 Orta'));
      await pumpFrames(tester);

      // Toggle Party Switch
      final partySwitch = find.byType(Switch);
      expect(partySwitch, findsOneWidget);
      await tester.tap(partySwitch);
      await pumpFrames(tester);

      // Win Condition toggle & change
      await tester.tap(find.text('Raund Sınırı'));
      await pumpFrames(tester);
      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await pumpFrames(tester);

      // Test on iPhone 14 Pro Max size too
      tester.view.physicalSize = const Size(430, 932);
      await pumpFrames(tester);

      expect(tester.takeException(), isNull, reason: 'SetupScreen hiçbir boyutta overflow vermemeli');
    });

    // 3. GameScreen - Idle, Active Play, Reveal, Pause, Exit Dialog
    testWidgets('3. GameScreen - Oyun akışı, kart açma, pas, duraklatma ve güvenli çıkış', (tester) async {
      tester.view.physicalSize = const Size(375, 667); // Small iPhone SE
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final config = GameConfig(
        gameMode: GameMode.individual,
        players: ['Ahmet', 'Elif'],
        teams: ['A Takımı', 'B Takımı'],
        duration: 60,
        passLimit: 2,
        category: MovieCategory.karisik,
        winCondition: WinCondition.score,
        targetScore: 3,
        rounds: 3,
        difficultySelection: DifficultySelection.hepsi,
        enablePartyChallenges: true,
      );
      final gameState = GameState(config: config);

      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        // ignore: avoid_print
        print('FLUTTER_ERROR_INTERCEPTED: ${details.exception}');
        // ignore: avoid_print
        print('FLUTTER_ERROR_CONTEXT: ${details.context}');
        // ignore: avoid_print
        print('FLUTTER_ERROR_INFORMATION_COLLECTOR: ${details.informationCollector?.call().map((d) => d.toString()).join('\n')}');
        oldOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldOnError);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(gameState: gameState),
        ),
      );
      await pumpFrames(tester);

      // Idle screen check
      expect(find.text('📣 Sıradaki Anlatıcı'), findsOneWidget);
      expect(find.text('Ahmet'), findsOneWidget);

      // Start Turn
      await tester.tap(find.text('Süreyi Başlat 🎬'));
      await pumpFrames(tester);

      // Hidden card check
      expect(find.text('Filmi Görmek İçin Tıklayın'), findsOneWidget);

      // Reveal card
      await tester.tap(find.text('Filmi Görmek İçin Tıklayın'));
      await pumpFrames(tester);
      expect(find.text('Gizlemek için dokunun'), findsOneWidget);

      // Pass movie
      final passBtn = find.text('Pas (2)');
      expect(passBtn, findsOneWidget);
      await tester.tap(passBtn);
      await pumpFrames(tester);
      expect(find.text('Pas (1)'), findsOneWidget);

      // Pause turn
      final pauseIcon = find.byIcon(Icons.pause_rounded);
      expect(pauseIcon, findsOneWidget);
      await tester.tap(pauseIcon);
      await pumpFrames(tester);
      expect(find.text('Oyun Duraklatıldı'), findsOneWidget);

      // Resume turn
      final playIcon = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playIcon);
      await pumpFrames(tester);
      expect(find.text('Oyun Duraklatıldı'), findsNothing);

      // Close (X) button -> Exit Confirmation Dialog
      final closeBtn = find.byIcon(Icons.close_rounded);
      await tester.tap(closeBtn);
      await pumpFrames(tester);
      expect(find.text('⚠️ Oyundan Çık?'), findsOneWidget);

      // Cancel exit
      await tester.tap(find.text('İptal'));
      await pumpFrames(tester);
      expect(find.text('⚠️ Oyundan Çık?'), findsNothing);

      // Clean up timer
      gameState.pauseTurn();
      final exception = tester.takeException();
      if (exception is FlutterError) {
        // ignore: avoid_print
        print('GameScreen Exception Details: ${exception.toStringDeep()}');
      } else if (exception != null) {
        // ignore: avoid_print
        print('GameScreen Exception Details: $exception');
      }
      expect(exception, isNull, reason: 'GameScreen akışında hata olmamalı');
    });

    // 4. ScoreboardScreen - Intermission & Final Winner Banner + MVP Badges
    testWidgets('4. ScoreboardScreen - Ara durum, Final şampiyonluk ve MVP rozetleri', (tester) async {
      tester.view.physicalSize = const Size(360, 640); // Compact screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final config = GameConfig(
        gameMode: GameMode.teams,
        players: ['Ahmet', 'Elif', 'Mehmet', 'Zeynep'],
        teams: ['A Takımı', 'B Takımı'],
        duration: 60,
        passLimit: 2,
        category: MovieCategory.karisik,
        winCondition: WinCondition.score,
        targetScore: 2,
        rounds: 2,
        difficultySelection: DifficultySelection.hepsi,
      );

      // 4a: Intermission (game NOT over yet)
      final intermissionState = GameState(config: config);
      intermissionState.scores['A Takımı'] = 1;
      intermissionState.scores['B Takımı'] = 1;
      intermissionState.isGameOver = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ScoreboardScreen(gameState: intermissionState, isIntermission: true),
        ),
      );
      await pumpFrames(tester);
      expect(find.text('📊 Puan Durumu'), findsOneWidget);
      expect(find.text('Sıradaki Oyuncuyla Devam Et ▶️'), findsOneWidget);

      // 4b: Final Game Over (FireworksCelebration & Final Winner Table)
      final finalState = GameState(config: config);
      finalState.scores['A Takımı'] = 2;
      finalState.scores['B Takımı'] = 1;
      finalState.isGameOver = true;
      finalState.winnerName = 'A Takımı';
      finalState.quickestGuesses['A Takımı'] = 14;
      finalState.maxStreaks['A Takımı'] = 2;
      finalState.passCounts['B Takımı'] = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: ScoreboardScreen(gameState: finalState, isIntermission: false),
        ),
      );
      await pumpFrames(tester, 3);
      expect(find.byType(FireworksCelebration), findsOneWidget);

      // Skip fireworks by tapping screen
      await tester.tap(find.byType(FireworksCelebration));
      await pumpFrames(tester);

      expect(find.text('🏆 Final Sıralaması'), findsOneWidget);
      expect(find.text('👑 KAZANAN 👑'), findsOneWidget);
      expect(find.text('A Takımı'), findsAtLeastNWidgets(1));
      expect(find.text('Gecenin Yıldızları'), findsOneWidget);
      expect(find.text('Yeniden Oyna 🔄'), findsOneWidget);
      expect(find.text('Ana Sayfaya Dön 🏠'), findsOneWidget);

      expect(tester.takeException(), isNull, reason: 'ScoreboardScreen hatasız çalışmalı');
    });

    // 5. CustomMoviesScreen - Add, View, Delete, Reset
    testWidgets('5. CustomMoviesScreen - Özel film ekleme, silme, responsive yapı', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: CustomMoviesScreen(),
        ),
      );
      await pumpFrames(tester);

      expect(find.byType(CustomMoviesScreen), findsOneWidget);
      expect(find.text('Özel Film Paketim'), findsOneWidget);

      // Enter movie title
      final input = find.widgetWithText(TextField, 'Film, dizi veya aranızdaki özel espri...');
      await tester.enterText(input, 'Gora');
      await tester.tap(find.text('🇹🇷 Yerli'));
      await pumpFrames(tester);

      // Tap Add
      await tester.tap(find.text('Listeme Ekle ➕'));
      await pumpFrames(tester);
      expect(find.text('Gora'), findsOneWidget);

      // Delete item
      final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
      if (deleteIcons.evaluate().isNotEmpty) {
        await tester.tap(deleteIcons.first);
        await pumpFrames(tester);
      }

      // Restore defaults
      await tester.tap(find.byTooltip('Varsayılan Popüler Dizileri Sıfırla'));
      await pumpFrames(tester);
      expect(find.text('Gibi'), findsOneWidget);

      expect(tester.takeException(), isNull, reason: 'CustomMoviesScreen hatasız çalışmalı');
    });
  });
}
