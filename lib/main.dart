import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'models/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress uncaught overflow warnings gracefully
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };

  runApp(const SessizlikApp());
}

class SessizlikApp extends StatelessWidget {
  const SessizlikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppThemeManager.instance,
      builder: (context, _) {
        final isDark = AppThemeManager.instance.isDarkMode;
        final textColor = AppThemeManager.instance.textColor;

        return MaterialApp(
          title: 'Sessizlik',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              brightness: isDark ? Brightness.dark : Brightness.light,
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              tertiary: AppColors.mint,
              background: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            ),
            scaffoldBackgroundColor: Colors.transparent, // Transparency for SoftBackground
            textTheme: TextTheme(
              displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(color: textColor),
              bodyMedium: TextStyle(color: textColor),
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.24),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.12),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
