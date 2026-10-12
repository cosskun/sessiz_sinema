import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/game_state.dart';
import '../models/game_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import '../widgets/fireworks_celebration.dart';
import '../models/app_theme.dart';

class ScoreboardScreen extends StatefulWidget {
  final GameState gameState;
  final bool isIntermission; // true if between turns, false if game over

  const ScoreboardScreen({
    super.key,
    required this.gameState,
    this.isIntermission = false,
  });

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late bool _showFireworks;

  @override
  void initState() {
    super.initState();
    // Show fireworks only on a final game over event, not on intermissions
    final isFinalGameOver = widget.gameState.isGameOver || !widget.isIntermission;
    _showFireworks = isFinalGameOver;
  }

  @override
  void didUpdateWidget(ScoreboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameState != oldWidget.gameState || widget.isIntermission != oldWidget.isIntermission) {
      _showFireworks = widget.gameState.isGameOver || !widget.isIntermission;
    }
  }

  String _getPlayersInTeam(String teamName) {
    List<String> teamPlayers = [];
    widget.gameState.playerTeams.forEach((player, team) {
      if (team == teamName) {
        teamPlayers.add(player);
      }
    });
    return teamPlayers.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final isFinalGameOver = state.isGameOver || !widget.isIntermission;
    
    // If we need to show fireworks celebration first
    if (isFinalGameOver && _showFireworks) {
      return Scaffold(
        body: FireworksCelebration(
          winnerName: state.winnerName ?? 'Bilinmeyen Oyuncu',
          onFinished: () {
            setState(() {
              _showFireworks = false;
            });
          },
        ),
      );
    }

    // Otherwise, show the ranked scoreboard screen
    final sortedScores = state.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: isFinalGameOver
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Header
                        Text(
                          '🏆 Final Sıralaması',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: AppThemeManager.instance.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Oyun bitti, tebrikler!',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Winner Announcement banner
                        GlassCard(
                          color: AppColors.mint.withOpacity(0.25),
                          borderOpacity: 0.3,
                          child: Column(
                            children: [
                              Text(
                                '👑 KAZANAN 👑',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemeManager.instance.textColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.winnerName ?? 'Bilinmeyen Oyuncu',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w900,
                                  color: AppThemeManager.instance.textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Scoreboard list in fixed or constrained container
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Derece',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeManager.instance.textColor),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Puan',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeManager.instance.textColor),
                                  ),
                                ],
                              ),
                              const Divider(height: 18),
                              ...sortedScores.asMap().entries.map((item) {
                                final index = item.key;
                                final entry = item.value;
                                return _buildScoreRow(entry, index, state);
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // MVP Section
                        _buildMvpSection(state),
                        const SizedBox(height: 20),

                        // Final Action Buttons
                        CustomButton(
                          text: 'Yeniden Oyna 🔄',
                          onPressed: () {
                            state.resetGame();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: 'Ana Sayfaya Dön 🏠',
                          color: Colors.white.withOpacity(0.5),
                          textColor: AppThemeManager.instance.textColor,
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        '📊 Puan Durumu',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: AppThemeManager.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mevcut sıralama',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Derece',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeManager.instance.textColor),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Puan',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeManager.instance.textColor),
                                  ),
                                ],
                              ),
                              const Divider(height: 18),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: sortedScores.length,
                                  itemBuilder: (context, index) {
                                    return _buildScoreRow(sortedScores[index], index, state);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        text: 'Sıradaki Oyuncuyla Devam Et ▶️',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(MapEntry<String, int> entry, int index, GameState state) {
    final isTop = index == 0;
    final isTeam = state.config.gameMode == GameMode.teams;

    Widget rankWidget;
    if (index == 0) {
      rankWidget = const Text('🥇 1.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else if (index == 1) {
      rankWidget = const Text('🥈 2.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else if (index == 2) {
      rankWidget = const Text('🥉 3.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    } else {
      rankWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${index + 1}.',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTop 
            ? AppColors.primary.withOpacity(0.12)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isTop ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          rankWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                    color: AppThemeManager.instance.textColor,
                  ),
                ),
                if (isTeam && state.config.players.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getPlayersInTeam(entry.key),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry.value}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isTop ? AppColors.primary : AppThemeManager.instance.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMvpSection(GameState state) {
    final fastest = state.fastestPlayer;
    final streak = state.streakChampion;
    final pass = state.passChampion;

    if (fastest == null && streak == null && pass == null) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Gecenin Yıldızları',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppThemeManager.instance.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (fastest != null)
                Expanded(
                  child: _buildMvpBadge('⚡ En Hızlı (${fastest.value}sn)', fastest.key, AppColors.mint),
                ),
              if (fastest != null && streak != null) const SizedBox(width: 8),
              if (streak != null)
                Expanded(
                  child: _buildMvpBadge('🎯 Seri (${streak.value}x)', streak.key, AppColors.primary),
                ),
              if ((fastest != null || streak != null) && pass != null) const SizedBox(width: 8),
              if (pass != null)
                Expanded(
                  child: _buildMvpBadge('🏃 Pas (${pass.value})', pass.key, AppColors.secondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMvpBadge(String label, String player, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              player,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppThemeManager.instance.textColor),
            ),
          ),
        ],
      ),
    );
  }
}
