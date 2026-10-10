import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Supported background & ambient gradient theme types.
enum AppThemeType {
  aurora, // Soft Lavender/Pink/Mint gradient (original)
  cinema, // Cinematic red/gold/slate gradient
  sunset, // Warm peach/orange gradient
  nordic, // Slate gray/ice blue minimal gradient
}

/// Singleton manager for light/dark mode and visual ambiance themes.
class AppThemeManager extends ChangeNotifier {
  static final AppThemeManager instance = AppThemeManager._internal();
  AppThemeManager._internal();

  bool _isDarkMode = false;
  AppThemeType _currentTheme = AppThemeType.aurora;

  bool get isDarkMode => _isDarkMode;
  AppThemeType get currentTheme => _currentTheme;

  Color get textColor => _isDarkMode ? AppColors.textLight : AppColors.textDark;
  Color get subtitleColor => _isDarkMode ? AppColors.textMutedLight : AppColors.textMutedDark;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(AppThemeType theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
