import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import 'game_screen.dart';
import '../models/app_theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  GameMode _gameMode = GameMode.individual;
  final List<String> _players = ['Ahmet', 'Elif', 'Mehmet', 'Zeynep'];
  final List<String> _teamAPlayers = ['Ahmet', 'Mehmet'];
  final List<String> _teamBPlayers = ['Elif', 'Zeynep'];
  final TextEditingController _playerController = TextEditingController();
  final TextEditingController _teamAController = TextEditingController();
  final TextEditingController _teamBController = TextEditingController();
  
  String _teamAName = 'A Takımı';
  String _teamBName = 'B Takımı';
  
  late final TextEditingController _teamANameController;
  late final TextEditingController _teamBNameController;

  double _duration = 60.0;
  int _passLimit = 2;
  MovieCategory _category = MovieCategory.karisik;
  DifficultySelection _difficulty = DifficultySelection.hepsi;
  
  WinCondition _winCondition = WinCondition.score;
  int _targetScore = 5;
  int _rounds = 3;
  bool _enablePartyChallenges = false;

  @override
  void initState() {
    super.initState();
    _teamANameController = TextEditingController(text: _teamAName);
    _teamBNameController = TextEditingController(text: _teamBName);
  }

  @override
  void dispose() {
    _playerController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _teamANameController.dispose();
    _teamBNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerController.text.trim();
    if (name.isNotEmpty) {
      if (_players.contains(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu oyuncu zaten eklenmiş!')),
        );
        return;
      }
      setState(() {
        _players.add(name);
        _playerController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _addTeamAPlayer() {
    final name = _teamAController.text.trim();
    if (name.isNotEmpty) {
      if (_teamAPlayers.contains(name) || _teamBPlayers.contains(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu oyuncu zaten eklenmiş!')),
        );
        return;
      }
      setState(() {
        _teamAPlayers.add(name);
        _teamAController.clear();
      });
    }
  }

  void _addTeamBPlayer() {
    final name = _teamBController.text.trim();
    if (name.isNotEmpty) {
      if (_teamAPlayers.contains(name) || _teamBPlayers.contains(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu oyuncu zaten eklenmiş!')),
        );
        return;
      }
      setState(() {
        _teamBPlayers.add(name);
        _teamBController.clear();
      });
    }
  }

  void _removeTeamAPlayer(int index) {
    setState(() {
      _teamAPlayers.removeAt(index);
    });
  }

  void _removeTeamBPlayer(int index) {
    setState(() {
      _teamBPlayers.removeAt(index);
    });
  }

  void _startGame() {
    final List<String> finalPlayers = [];
    final Map<String, String> playerToTeam = {};

    if (_gameMode == GameMode.individual) {
      if (_players.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyuna başlamak için en az 2 oyuncu eklemelisiniz!')),
        );
        return;
      }
      finalPlayers.addAll(_players);
    } else {
      if (_teamAPlayers.isEmpty || _teamBPlayers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Her iki takıma da en az 1 oyuncu eklemelisiniz!')),
        );
        return;
      }
      
      // Interleave players so that play alternates between teams (e.g. A1, B1, A2, B2...)
      final int maxLen = _teamAPlayers.length > _teamBPlayers.length ? _teamAPlayers.length : _teamBPlayers.length;
      for (int i = 0; i < maxLen; i++) {
        if (i < _teamAPlayers.length) {
          finalPlayers.add(_teamAPlayers[i]);
          playerToTeam[_teamAPlayers[i]] = _teamAName.trim().isEmpty ? 'A Takımı' : _teamAName;
        }
        if (i < _teamBPlayers.length) {
          finalPlayers.add(_teamBPlayers[i]);
          playerToTeam[_teamBPlayers[i]] = _teamBName.trim().isEmpty ? 'B Takımı' : _teamBName;
        }
      }
    }

    final config = GameConfig(
      gameMode: _gameMode,
      players: finalPlayers,
      teams: [_teamAName.trim().isEmpty ? 'A Takımı' : _teamAName, _teamBName.trim().isEmpty ? 'B Takımı' : _teamBName],
      duration: _duration.toInt(),
      passLimit: _passLimit,
      category: _category,
      winCondition: _winCondition,
      targetScore: _targetScore,
      rounds: _rounds,
      difficultySelection: _difficulty,
      playerToTeam: _gameMode == GameMode.teams ? playerToTeam : null,
      enablePartyChallenges: _enablePartyChallenges,
    );

    final gameState = GameState(config: config);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(gameState: gameState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppThemeManager.instance.textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Oyun Ayarları',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: AppThemeManager.instance.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Mode Selector
                    _buildSectionTitle('🎮 Oyun Modu'),
                    _buildModeSelector(),
                    const SizedBox(height: 20),

                    // Team Name input (if Team Mode)
                    if (_gameMode == GameMode.teams) ...[
                      _buildSectionTitle('👥 Takım İsimleri'),
                      _buildTeamNamesInput(),
                      const SizedBox(height: 20),
                    ],

                    // Players Section
                    _buildSectionTitle(_gameMode == GameMode.individual
                        ? '👤 Oyuncular (${_players.length})'
                        : '👤 Takım Oyuncuları (${_teamAPlayers.length + _teamBPlayers.length})'),
                    _buildPlayersSection(),
                    const SizedBox(height: 20),

                    // Setup parameters (Duration, Category, Pass limit)
                    _buildSectionTitle('⚙️ Oyun Parametreleri'),
                    _buildGameParametersSection(),
                    const SizedBox(height: 20),

                    // Party Challenges (Meydan Okuma Modu)
                    _buildSectionTitle('🃏 Eğlenceli Parti Modu'),
                    _buildPartyChallengeSection(),
                    const SizedBox(height: 20),

                    // Win Condition (Target score / rounds)
                    _buildSectionTitle('🏆 Kazanma Koşulu'),
                    _buildWinConditionSection(),
                    const SizedBox(height: 32),

                    // Play Button
                    CustomButton(
                      text: 'Oyunu Başlat 🚀',
                      fontSize: 18.0,
                      color: AppColors.primary,
                      onPressed: _startGame,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: AppThemeManager.instance.textColor,
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _gameMode = GameMode.individual),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                decoration: BoxDecoration(
                  color: _gameMode == GameMode.individual
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: Text(
                    'Herkes Tek',
                    style: TextStyle(
                      color: _gameMode == GameMode.individual ? Colors.white : AppThemeManager.instance.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _gameMode = GameMode.teams),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                decoration: BoxDecoration(
                  color: _gameMode == GameMode.teams
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: Text(
                    'Takımlı',
                    style: TextStyle(
                      color: _gameMode == GameMode.teams ? Colors.white : AppThemeManager.instance.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamNamesInput() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Takım İsmi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.teamA,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _teamANameController,
            decoration: InputDecoration(
              hintText: '1. Takım İsmi (Örn: A Takımı)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              prefixIcon: const Icon(Icons.group_rounded, color: AppColors.teamA, size: 20),
            ),
            onChanged: (val) {
              setState(() {
                _teamAName = val;
              });
            },
          ),
          const SizedBox(height: 14),
          Text(
            '2. Takım İsmi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.teamB,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _teamBNameController,
            decoration: InputDecoration(
              hintText: '2. Takım İsmi (Örn: B Takımı)',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              prefixIcon: const Icon(Icons.group_rounded, color: AppColors.teamB, size: 20),
            ),
            onChanged: (val) {
              setState(() {
                _teamBName = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection() {
    if (_gameMode == GameMode.teams) {
      final teamADisplayName = _teamAName.trim().isEmpty ? "A Takımı" : _teamAName;
      final teamBDisplayName = _teamBName.trim().isEmpty ? "B Takımı" : _teamBName;

      return Column(
        children: [
          // Team A Card
          GlassCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teamA.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '1. Takım',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.teamA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        teamADisplayName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '(${_teamAPlayers.length} Oyuncu)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _teamAController,
                        decoration: InputDecoration(
                          hintText: '$teamADisplayName için oyuncu adı...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                        ),
                        onSubmitted: (_) => _addTeamAPlayer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addTeamAPlayer,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Icon(Icons.add, color: AppThemeManager.instance.textColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _teamAPlayers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Henüz oyuncu eklenmedi.',
                          style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _teamAPlayers.length,
                          itemBuilder: (context, index) {
                            final name = _teamAPlayers[index];
                            return _buildPlayerRow(name, AppColors.teamA, () => _removeTeamAPlayer(index));
                          },
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Team B Card
          GlassCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teamB.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '2. Takım',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.teamB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        teamBDisplayName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '(${_teamBPlayers.length} Oyuncu)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _teamBController,
                        decoration: InputDecoration(
                          hintText: '$teamBDisplayName için oyuncu adı...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                        ),
                        onSubmitted: (_) => _addTeamBPlayer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addTeamBPlayer,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Icon(Icons.add, color: AppThemeManager.instance.textColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _teamBPlayers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Henüz oyuncu eklenmedi.',
                          style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _teamBPlayers.length,
                          itemBuilder: (context, index) {
                            final name = _teamBPlayers[index];
                            return _buildPlayerRow(name, AppColors.teamB, () => _removeTeamBPlayer(index));
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      );
    }

    // Individual mode (default list)
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _playerController,
                  decoration: InputDecoration(
                    hintText: 'Oyuncu adı yazın...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                  onSubmitted: (_) => _addPlayer(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addPlayer,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Icon(Icons.add, color: AppThemeManager.instance.textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _players.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Henüz oyuncu eklenmedi.',
                    style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                )
              : Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final name = _players[index];
                      final color = index % 2 == 0 ? AppColors.primary : AppColors.secondary;
                      return _buildPlayerRow(name, color, () => _removePlayer(index));
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(String name, Color color, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'O',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameParametersSection() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⏱️ Anlatım Süresi',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
              ),
              Text(
                '${_duration.toInt()} Saniye',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: _duration,
            min: 30.0,
            max: 180.0,
            divisions: 10,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white.withOpacity(0.5),
            onChanged: (val) {
              setState(() {
                _duration = val;
              });
            },
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Pass Limit Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔄 Pas Hakkı',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
              ),
              Row(
                children: [0, 1, 2, 3, 5].map((passes) {
                  final isSelected = _passLimit == passes;
                  return GestureDetector(
                    onTap: () => setState(() => _passLimit = passes),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '$passes',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppThemeManager.instance.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // Movie Category Selection
          Text(
            '🎬 Film Kategorisi',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(MovieCategory.karisik, '🔀 Karışık'),
                const SizedBox(width: 8),
                _buildCategoryChip(MovieCategory.yerli, '🇹🇷 Yerli'),
                const SizedBox(width: 8),
                _buildCategoryChip(MovieCategory.yabanci, '🌍 Yabancı'),
                const SizedBox(width: 8),
                _buildCategoryChip(MovieCategory.ozel, '⭐ Özel'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          // Movie Difficulty Selection
          Text(
            '⚡ Zorluk Seviyesi',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDifficultyChip(DifficultySelection.hepsi, '🌟 Hepsi'),
                const SizedBox(width: 8),
                _buildDifficultyChip(DifficultySelection.kolay, '🟢 Kolay'),
                const SizedBox(width: 8),
                _buildDifficultyChip(DifficultySelection.orta, '🟡 Orta'),
                const SizedBox(width: 8),
                _buildDifficultyChip(DifficultySelection.zor, '🔴 Zor'),
                const SizedBox(width: 8),
                _buildDifficultyChip(DifficultySelection.cokZor, '💀 Çok Zor'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyChallengeSection() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentWarning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🃏', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meydan Okuma Modu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppThemeManager.instance.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Her turda anlatan kişiye komik kurallar & handikaplar çıkar!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enablePartyChallenges,
            activeColor: AppColors.accentWarning,
            onChanged: (val) {
              setState(() {
                _enablePartyChallenges = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(DifficultySelection selection, String label) {
    final isSelected = _difficulty == selection;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = selection),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.difficultyHard : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.difficultyHard : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppThemeManager.instance.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(MovieCategory category, String label) {
    final isSelected = _category == category;
    return GestureDetector(
      onTap: () => setState(() => _category = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppThemeManager.instance.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinConditionSection() {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _winCondition = WinCondition.score),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: _winCondition == WinCondition.score
                          ? AppColors.mint
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        'Hedef Skor',
                        style: TextStyle(
                          color: AppThemeManager.instance.textColor,
                          fontWeight: _winCondition == WinCondition.score ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _winCondition = WinCondition.rounds),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: _winCondition == WinCondition.rounds
                          ? AppColors.mint
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        'Raund Sınırı',
                        style: TextStyle(
                          color: AppThemeManager.instance.textColor,
                          fontWeight: _winCondition == WinCondition.rounds ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _winCondition == WinCondition.score
                    ? '🎯 Kazanılacak Puan'
                    : '🔁 Toplam Raund',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_winCondition == WinCondition.score) {
                          if (_targetScore > 1) _targetScore--;
                        } else {
                          if (_rounds > 1) _rounds--;
                        }
                      });
                    },
                    icon: Icon(Icons.remove_circle_outline_rounded, color: AppThemeManager.instance.textColor),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        _winCondition == WinCondition.score ? '$_targetScore' : '$_rounds',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeManager.instance.textColor),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_winCondition == WinCondition.score) {
                          _targetScore++;
                        } else {
                          _rounds++;
                        }
                      });
                    },
                    icon: Icon(Icons.add_circle_outline_rounded, color: AppThemeManager.instance.textColor),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

extension ContainerWidth on Widget {
  Widget get minWidthBox => SizedBox(width: double.infinity, child: this);
}
