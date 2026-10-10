import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/game_state.dart';
import '../models/game_config.dart';
import '../models/movie.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import 'scoreboard_screen.dart';
import '../models/app_theme.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
      // If the game ends from background timer, redirect to final ScoreboardScreen once
      if (widget.gameState.isGameOver && !_isNavigating) {
        _isNavigating = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ScoreboardScreen(gameState: widget.gameState, isIntermission: false),
              ),
            );
          }
        });
      }
    }
  }

  void _confirmExit() {
    widget.gameState.pauseTurn();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⚠️ Oyundan Çık?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'Mevcut oyun durumunuz kaybolacak. Çıkmak istediğinize emin misiniz?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppThemeManager.instance.textColor),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'İptal',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.gameState.resumeTurn();
                        },
                        color: Colors.white.withOpacity(0.5),
                        textColor: AppThemeManager.instance.textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Çıkış',
                        onPressed: () {
                          _isNavigating = true;
                          widget.gameState.pauseTurn();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        color: Colors.redAccent.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTimerColor(int seconds) {
    if (seconds > 30) return AppColors.mint;
    if (seconds > 10) return AppColors.peach;
    return AppColors.rose;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final config = state.config;

    return WillPopScope(
      onWillPop: () async {
        _confirmExit();
        return false;
      },
      child: Scaffold(
        body: SoftBackground(
          child: Column(
            children: [
              // Top Bar (Score summary, Pause/Quit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppThemeManager.instance.textColor, size: 28),
                      onPressed: _confirmExit,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.repeat, size: 16, color: AppThemeManager.instance.textColor),
                          const SizedBox(width: 4),
                          Text(
                            config.winCondition == WinCondition.rounds
                                ? 'Raund: ${state.currentRound}/${config.rounds}'
                                : 'Raund: ${state.currentRound}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppThemeManager.instance.textColor),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (state.isTurnRunning) ...[
                      IconButton(
                        icon: Icon(
                          state.isTurnPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: AppThemeManager.instance.textColor,
                          size: 28,
                        ),
                        onPressed: () {
                          if (state.isTurnPaused) {
                            state.resumeTurn();
                          } else {
                            state.pauseTurn();
                          }
                        },
                      ),
                    ] else ...[
                      const SizedBox(width: 48),
                    ],
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: state.isTurnRunning
                      ? _buildActiveGameplayLayout(state)
                      : _buildIdleTurnLayout(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shown when players are waiting for their turn
  Widget _buildIdleTurnLayout(GameState state) {
    final hasTeam = state.config.gameMode == GameMode.teams;
    final teamName = state.activePlayerTeam;
    final isTeamA = teamName == state.config.teams[0];
    final teamColor = isTeamA ? AppColors.teamA : AppColors.teamB;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 26.0),
            child: Column(
              children: [
                Text(
                  '📣 Sıradaki Anlatıcı',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Text(
                  state.activePlayerName,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w900,
                    color: AppThemeManager.instance.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasTeam && teamName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: teamColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: teamColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      teamName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: teamColor,
                      ),
                    ),
                  ),
                ],
                if (state.config.enablePartyChallenges && state.currentChallenge != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentWarning.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentWarning, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.currentChallenge!.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            const Text(
                              '🃏 Meydan Okuma Handikapı:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.currentChallenge!.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppThemeManager.instance.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Hazır olduğunuzda süreyi başlatın.\nFilmi sadece hareketlerinizle anlatacaksınız!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.0, color: const Color(0xFF5E6E8C), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Süreyi Başlat 🎬',
            fontSize: 17.0,
            color: AppColors.primary,
            onPressed: () {
              state.startTurn();
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Skor Tablosunu Gör',
            color: Colors.white.withOpacity(0.5),
            textColor: AppThemeManager.instance.textColor,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScoreboardScreen(gameState: state, isIntermission: true),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Gameplay timer and card display
  Widget _buildActiveGameplayLayout(GameState state) {
    final timerColor = _getTimerColor(state.timerSeconds);
    final percentage = state.timerSeconds / state.config.duration;

    return Column(
      children: [
        const SizedBox(height: 6),
        // Compact Top Header: Timer ring + Active Player
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.timerSeconds}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: state.timerSeconds <= 10 ? AppColors.rose : AppThemeManager.instance.textColor,
                      ),
                    ),
                    Text(
                      'sn',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Player info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.activePlayerName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppThemeManager.instance.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.config.gameMode == GameMode.teams && state.activePlayerTeam != null
                      ? '${state.activePlayerTeam} • Anlatıyor'
                      : 'Sıradaki Oyuncu Anlatıyor',
                  style: TextStyle(
                    fontSize: 12,
                    color: state.activePlayerTeam == state.config.teams[0]
                        ? AppColors.teamA
                        : (state.activePlayerTeam != null ? AppColors.teamB : Colors.grey.shade700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        if (state.config.enablePartyChallenges && state.currentChallenge != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentWarning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentWarning.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.currentChallenge!.icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    state.currentChallenge!.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppThemeManager.instance.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 6),

        // Movie Card (Single Elegant Panel - Zero Scrolling Needed)
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: state.toggleMovieReveal,
              child: GlassCard(
                color: state.isMovieRevealed ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.4),
                borderOpacity: state.isMovieRevealed ? 0.4 : 0.1,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: state.isTurnPaused
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pause_circle_filled_rounded, size: 54, color: AppThemeManager.instance.textColor),
                            const SizedBox(height: 8),
                            Text(
                              'Oyun Duraklatıldı',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Devam etmek için üstteki oynat ikonuna basın.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        )
                      : AnimatedCrossFade(
                          firstChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.visibility_off_rounded, size: 48, color: AppColors.primary),
                              const SizedBox(height: 14),
                              Text(
                                'Filmi Görmek İçin Tıklayın',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemeManager.instance.textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Diğer oyuncuların görmemesi için gizlidir.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0, color: Color(0xFF5E6E8C)),
                              ),
                            ],
                          ),
                          secondChild: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Badges row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: state.currentMovie.isYerli ? AppColors.mint : AppColors.peach,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      state.currentMovie.originBadge,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: state.currentMovie.difficulty.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: state.currentMovie.difficulty.color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      state.currentMovie.difficulty.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: state.currentMovie.difficulty.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Poster (if available, compact and sleek)
                              if (state.currentMovie.posterUrl != null && state.currentMovie.posterUrl!.isNotEmpty)
                                Container(
                                  height: 95,
                                  width: 68,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      state.currentMovie.posterUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.white.withOpacity(0.3),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200.withOpacity(0.5),
                                          child: const Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 24),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              // Title - Grand and clear
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    state.currentMovie.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: state.currentMovie.title.length > 25
                                          ? 22.0
                                          : 28.0,
                                      fontWeight: FontWeight.w900,
                                      color: AppThemeManager.instance.textColor,
                                      height: 1.15,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              // Bottom hint
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.visibility_rounded, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'Gizlemek için dokunun',
                                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          crossFadeState: state.isMovieRevealed
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Action Buttons
        if (!state.isTurnPaused) ...[
          Row(
            children: [
              // Pass Button
              Expanded(
                child: CustomButton(
                  text: 'Pas (${state.remainingPasses})',
                  icon: Icons.repeat_rounded,
                  color: AppColors.secondary,
                  onPressed: state.remainingPasses > 0 ? () => state.passMovie() : null,
                ),
              ),
              const SizedBox(width: 12),
              // Guessed (Success) Button
              Expanded(
                child: CustomButton(
                  text: 'Bildi ✓',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.mint,
                  textColor: AppThemeManager.instance.textColor,
                  onPressed: () {
                    state.scorePoint();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Tebrikler! Puan eklendi.'),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                    if (state.isGameOver) {
                      _isNavigating = true;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ScoreboardScreen(gameState: state, isIntermission: false),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScoreboardScreen(gameState: state, isIntermission: true),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Süreyi Bitir ✗',
            color: Colors.white.withOpacity(0.5),
            textColor: AppThemeManager.instance.textColor,
            onPressed: () {
              state.failTurn();
              if (state.isGameOver) {
                _isNavigating = true;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ScoreboardScreen(gameState: state, isIntermission: false),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ScoreboardScreen(gameState: state, isIntermission: true),
                  ),
                );
              }
            },
          ),
        ] else ...[
          const SizedBox(height: 110), // spacing placeholder when paused
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
