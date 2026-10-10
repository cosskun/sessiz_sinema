import 'movie.dart';

/// Repository & Manager for custom user-created movie and TV show cards.
class CustomMovieManager {
  static final CustomMovieManager instance = CustomMovieManager._internal();
  CustomMovieManager._internal() {
    _initializeDefaultCustomMovies();
  }

  final List<Movie> _customMovies = [];

  /// Unmodifiable view of custom movies
  List<Movie> get movies => List.unmodifiable(_customMovies);

  /// Pre-populates the custom list with popular cult Turkish/Foreign series
  void _initializeDefaultCustomMovies() {
    if (_customMovies.isEmpty) {
      _customMovies.addAll(const [
        Movie(title: 'Gibi', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Prens', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Kurtlar Vadisi', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Avrupa Yakası', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Leyla ile Mecnun', isYerli: true, difficulty: MovieDifficulty.orta),
        Movie(title: 'Ölümlü Dünya', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Cinayet Süsü', isYerli: true, difficulty: MovieDifficulty.orta),
        Movie(title: 'Yahşi Batı', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'G.O.R.A', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'A.R.O.G', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Ezel', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Kardeş Payı', isYerli: true, difficulty: MovieDifficulty.orta),
        Movie(title: 'İşler Güçler', isYerli: true, difficulty: MovieDifficulty.orta),
        Movie(title: 'Behzat Ç.', isYerli: true, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Squid Game', isYerli: false, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Stranger Things', isYerli: false, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Breaking Bad', isYerli: false, difficulty: MovieDifficulty.kolay),
        Movie(title: 'Game of Thrones', isYerli: false, difficulty: MovieDifficulty.orta),
      ]);
    }
  }

  /// Adds a new custom movie card. Returns false if title is empty or already exists.
  bool addMovie(
    String title, {
    bool isYerli = true,
    MovieDifficulty difficulty = MovieDifficulty.orta,
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return false;

    // Duplicate check
    final isDuplicate = _customMovies.any(
      (m) => m.title.toLowerCase() == cleanTitle.toLowerCase(),
    );
    if (isDuplicate) return false;

    _customMovies.insert(
      0,
      Movie(
        title: cleanTitle,
        isYerli: isYerli,
        difficulty: difficulty,
      ),
    );
    return true;
  }

  /// Removes a movie at the specified index
  void removeMovie(int index) {
    if (index >= 0 && index < _customMovies.length) {
      _customMovies.removeAt(index);
    }
  }

  /// Resets the list back to default popular titles
  void resetToDefaults() {
    _customMovies.clear();
    _initializeDefaultCustomMovies();
  }
}
