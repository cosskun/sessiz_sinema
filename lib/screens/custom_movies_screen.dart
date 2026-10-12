import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/app_theme.dart';
import '../models/custom_movie_manager.dart';
import '../models/movie.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';

class CustomMoviesScreen extends StatefulWidget {
  const CustomMoviesScreen({super.key});

  @override
  State<CustomMoviesScreen> createState() => _CustomMoviesScreenState();
}

class _CustomMoviesScreenState extends State<CustomMoviesScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isYerli = true;
  MovieDifficulty _difficulty = MovieDifficulty.orta;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addMovie() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir film veya dizi adı yazın!')),
      );
      return;
    }

    final success = CustomMovieManager.instance.addMovie(
      title,
      isYerli: _isYerli,
      difficulty: _difficulty,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu yapım zaten özel listenizde ekli!')),
      );
      return;
    }

    _titleController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🎉 "$title" özel paketinize eklendi!'), duration: const Duration(milliseconds: 900)),
    );
  }

  void _deleteMovie(int index) {
    setState(() {
      CustomMovieManager.instance.removeMovie(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = CustomMovieManager.instance.movies;

    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: Column(
            children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppThemeManager.instance.textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Özel Film Paketim',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppThemeManager.instance.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Varsayılan Popüler Dizileri Sıfırla',
                    icon: Icon(Icons.restore_rounded, color: AppThemeManager.instance.textColor),
                    onPressed: () {
                      setState(() {
                        CustomMovieManager.instance.resetToDefaults();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Özel paket varsayılan popüler dizilerle yenilendi!')),
                      );
                    },
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
                    // Add Card
                    GlassCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✍️ Yeni Film / Dizi Ekle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppThemeManager.instance.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Film, dizi veya aranızdaki özel espri...',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                              prefixIcon: const Icon(Icons.movie_filter_rounded, color: AppColors.primary),
                            ),
                            onSubmitted: (_) => _addMovie(),
                          ),
                          const SizedBox(height: 12),
                          // Yerli / Yabancı Selector
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isYerli = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isYerli ? AppColors.mint : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '🇹🇷 Yerli',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppThemeManager.instance.textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isYerli = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isYerli ? AppColors.peach : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '🌍 Yabancı',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppThemeManager.instance.textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Difficulty selector
                          Row(
                            children: MovieDifficulty.values.map((diff) {
                              final isSelected = _difficulty == diff;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _difficulty = diff),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? diff.color : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        diff.label.replaceAll('⚡ ', ''),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: AppThemeManager.instance.textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          CustomButton(
                            text: 'Listeme Ekle ➕',
                            fontSize: 14,
                            color: AppColors.primary,
                            onPressed: _addMovie,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // List Section Header
                    Text(
                      '📋 Ekli Filmler & Diziler (${movies.length})',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppThemeManager.instance.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Movie List
                    if (movies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(
                          child: Text(
                            'Henüz özel bir yapım eklemediniz.\nYukarıdaki kutudan hemen ekleyebilirsiniz!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: movie.isYerli ? AppColors.mint : AppColors.peach,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    movie.isYerli ? '🇹🇷' : '🌍',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    movie.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppThemeManager.instance.textColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: movie.difficulty.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    movie.difficulty.label.replaceAll('⚡ ', ''),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: movie.difficulty.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => _deleteMovie(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
}
