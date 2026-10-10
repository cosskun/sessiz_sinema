import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sessizlik/main.dart';
import 'package:sessizlik/screens/game_screen.dart';
import 'package:sessizlik/screens/home_screen.dart';

void main() {
  testWidgets('Sessizlik App rendering test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SessizlikApp());

    // Verify that our app starts with the "Sessizlik" title and main buttons.
    expect(find.text('Sessizlik'), findsOneWidget);
    expect(find.text('Oyunu Özelleştir & Kur'), findsOneWidget);
    expect(find.text('⚡ Hızlı Başla (60 sn)'), findsOneWidget);
  });

  testWidgets('Hızlı Başla ile oyuna girip çıkınca Ana Sayfaya sorunsuz dönmeli (Siyah ekran olmamalı)', (WidgetTester tester) async {
    await tester.pumpWidget(const SessizlikApp());
    await tester.pumpAndSettle();

    // Tap Quick Play button
    final quickPlayBtn = find.text('⚡ Hızlı Başla (60 sn)');
    expect(quickPlayBtn, findsOneWidget);
    await tester.tap(quickPlayBtn);
    await tester.pumpAndSettle();

    // Verify GameScreen is displayed
    expect(find.byType(GameScreen), findsOneWidget);

    // Tap Close (X) button
    final closeBtn = find.byIcon(Icons.close_rounded);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog is visible
    expect(find.text('⚠️ Oyundan Çık?'), findsOneWidget);

    // Tap 'Çıkış' button in dialog
    final exitBtn = find.text('Çıkış');
    expect(exitBtn, findsOneWidget);
    await tester.tap(exitBtn);
    await tester.pumpAndSettle();

    // Verify that HomeScreen is rendered safely and not popped to black screen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Sessizlik'), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
  });
}
