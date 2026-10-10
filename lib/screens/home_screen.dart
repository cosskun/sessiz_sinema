import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/app_theme.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import 'custom_movies_screen.dart';
import 'game_screen.dart';
import 'setup_screen.dart';

/// Home landing screen of Sessizlik.
/// Provides quick game start, custom setup, custom movie package access, themes, and sound toggles.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _startQuickPlay(BuildContext context) {
    final config = GameConfig.quickPlay();
    final gameState = GameState(config: config);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(gameState: gameState)),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: GlassCard(
            blur: 20,
            color: Colors.white.withOpacity(0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🎭 Nasıl Oynanır?',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: AppThemeManager.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Sessizlik Kuralları:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppThemeManager.instance.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRuleItem('1️⃣', 'Mod Seçimi', 'İster "Takımlı" oynayıp iki gruba ayrılın, ister "Herkes Tek" moduyla bireysel yarışın.'),
                _buildRuleItem('2️⃣', 'Film Anlatımı', 'Sırası gelen oyuncu film ismini sadece jest ve mimiklerle (kelime söylemeden, ses çıkartmadan) anlatır.'),
                _buildRuleItem('3️⃣', 'Süre ve Pas', 'Her oyuncunun filmi anlatmak için kısıtlı süresi vardır. Zorlandığı filmleri "Pas" butonu ile değiştirebilir.'),
                _buildRuleItem('4️⃣', 'Puanlama', 'Doğru tahmin durumunda "+1 Puan" kazanılır. Hedef skora ulaşan ilk oyuncu veya takım kazanır.'),
                _buildRuleItem('5️⃣', '🃏 Meydan Okuma', 'İsteğe bağlı handikap moduyla (örn: "Sadece yüz mimikleri", "Oturarak anlat") ekstra kahkaha katabilirsiniz!'),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Anladım, Başlayalım!',
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppThemeManager.instance.textColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '🎨 Tema Seçimi',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppThemeManager.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: AppThemeManager.instance,
                  builder: (context, _) {
                    final current = AppThemeManager.instance.currentTheme;
                    return Column(
                      children: [
                        _buildThemeOptionTile(
                          context,
                          theme: AppThemeType.aurora,
                          name: 'Aurora (Pastel)',
                          desc: 'Yumuşak lavanta, pembe ve nane tonları',
                          isSelected: current == AppThemeType.aurora,
                          gradient: const [Color(0xFF8E9DF7), Color(0xFFF78EAE), Color(0xFF8EF7CD)],
                        ),
                        const SizedBox(height: 8),
                        _buildThemeOptionTile(
                          context,
                          theme: AppThemeType.cinema,
                          name: 'Cinema (Klasik Sinema)',
                          desc: 'Kadife kırmızısı, altın sarısı ve sinema salonu',
                          isSelected: current == AppThemeType.cinema,
                          gradient: const [Color(0xFFF78E8E), Color(0xFFF7D08E), Color(0xFF8EBEF7)],
                        ),
                        const SizedBox(height: 8),
                        _buildThemeOptionTile(
                          context,
                          theme: AppThemeType.sunset,
                          name: 'Sunset (Günbatımı)',
                          desc: 'Sıcak şeftali, mercan ve altın tonları',
                          isSelected: current == AppThemeType.sunset,
                          gradient: const [Color(0xFFF7A28E), Color(0xFFF78EC8), Color(0xFFDFE68E)],
                        ),
                        const SizedBox(height: 8),
                        _buildThemeOptionTile(
                          context,
                          theme: AppThemeType.nordic,
                          name: 'Nordic (Minimalist)',
                          desc: 'Sade antrasit, buz mavisi ve kurşuni minimalizm',
                          isSelected: current == AppThemeType.nordic,
                          gradient: const [Color(0xFF90A4AE), Color(0xFFB0BEC5), Color(0xFF78909C)],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required AppThemeType theme,
    required String name,
    required String desc,
    required bool isSelected,
    required List<Color> gradient,
  }) {
    final isDark = AppThemeManager.instance.isDarkMode;
    return GestureDetector(
      onTap: () {
        AppThemeManager.instance.setTheme(theme);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(isDark ? 0.25 : 0.18)
              : Colors.white.withOpacity(isDark ? 0.05 : 0.4),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppThemeManager.instance.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Column(
                        children: [
                          // Top Action Bar for Settings (Theme, Dark Mode, Sound)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ListenableBuilder(
                                listenable: AppThemeManager.instance,
                                builder: (context, _) {
                                  final isDark = AppThemeManager.instance.isDarkMode;
                                  final iconColor = isDark ? Colors.white : AppThemeManager.instance.textColor;
                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          SoundService.instance.isSoundEnabled
                                              ? Icons.volume_up_rounded
                                              : Icons.volume_off_rounded,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                        tooltip: SoundService.instance.isSoundEnabled ? 'Sesi Kapat' : 'Sesi Aç',
                                        onPressed: () {
                                          setState(() {
                                            SoundService.instance.toggleSound();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.palette_outlined, color: iconColor, size: 24),
                                        tooltip: 'Tema Değiştir',
                                        onPressed: () => _showThemeSelectorDialog(context),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                        tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
                                        onPressed: () {
                                          AppThemeManager.instance.toggleDarkMode();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const Spacer(flex: 1),
                          const SizedBox(height: 8),

                          // Title & Visual Clapperboard Area
                          Hero(
                            tag: 'app_title',
                            child: Column(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.35),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25.5),
                                    child: Image.asset(
                                      'assets/icon/app_icon.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Text(
                                            '🤫🎬',
                                            style: TextStyle(fontSize: 48),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    fontSize: 34.0,
                                    fontWeight: FontWeight.w900,
                                    color: AppThemeManager.instance.textColor,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ListenableBuilder(
                                  listenable: AppThemeManager.instance,
                                  builder: (context, _) {
                                    final isDark = AppThemeManager.instance.isDarkMode;
                                    return Text(
                                      AppStrings.appTagline,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                          const SizedBox(height: 12),

                          // Action Buttons
                          GlassCard(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Quick Play Button
                                CustomButton(
                                  text: '⚡ Hızlı Başla (60 sn)',
                                  icon: Icons.flash_on_rounded,
                                  color: AppColors.mint,
                                  textColor: AppThemeManager.instance.textColor,
                                  onPressed: () => _startQuickPlay(context),
                                ),
                                const SizedBox(height: 10),
                                // Standard Game Setup
                                CustomButton(
                                  text: 'Oyunu Özelleştir & Kur',
                                  icon: Icons.tune_rounded,
                                  color: AppColors.primary,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SetupScreen()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                // Row with Custom Movies & How to Play
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListenableBuilder(
                                        listenable: AppThemeManager.instance,
                                        builder: (context, _) {
                                          final isDark = AppThemeManager.instance.isDarkMode;
                                          return CustomButton(
                                            text: '✍️ Özel Paket',
                                            color: Colors.white.withOpacity(isDark ? 0.15 : 0.8),
                                            textColor: AppColors.secondary,
                                            fontSize: 13,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => const CustomMoviesScreen()),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ListenableBuilder(
                                        listenable: AppThemeManager.instance,
                                        builder: (context, _) {
                                          final isDark = AppThemeManager.instance.isDarkMode;
                                          return CustomButton(
                                            text: '❓ Kurallar',
                                            color: Colors.white.withOpacity(isDark ? 0.15 : 0.8),
                                            textColor: AppColors.primary,
                                            fontSize: 13,
                                            onPressed: () => _showHowToPlayDialog(context),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
