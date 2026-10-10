import 'package:flutter/material.dart';
import '../models/app_theme.dart';

/// Ambient living gradient background with floating blurred color spheres.
class SoftBackground extends StatelessWidget {
  final Widget child;

  const SoftBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppThemeManager.instance,
      builder: (context, _) {
        final manager = AppThemeManager.instance;
        final isDark = manager.isDarkMode;

        List<Color> gradientColors;
        Color blob1Color;
        Color blob2Color;
        Color blob3Color;

        switch (manager.currentTheme) {
          case AppThemeType.aurora:
            gradientColors = isDark
                ? [const Color(0xFF111424), const Color(0xFF1F121C), const Color(0xFF121B1A)]
                : [const Color(0xFFE8EBFA), const Color(0xFFFBECEF), const Color(0xFFE3F4F0)];
            blob1Color = const Color(0xFF8E9DF7).withOpacity(isDark ? 0.12 : 0.18);
            blob2Color = const Color(0xFFF78EAE).withOpacity(isDark ? 0.12 : 0.18);
            blob3Color = const Color(0xFF8EF7CD).withOpacity(isDark ? 0.10 : 0.15);
            break;
          case AppThemeType.cinema:
            gradientColors = isDark
                ? [const Color(0xFF1E1010), const Color(0xFF1E1610), const Color(0xFF0F131C)]
                : [const Color(0xFFFFF2F2), const Color(0xFFFFF9E6), const Color(0xFFE6F0FA)];
            blob1Color = const Color(0xFFF78E8E).withOpacity(isDark ? 0.12 : 0.18);
            blob2Color = const Color(0xFFF7D08E).withOpacity(isDark ? 0.10 : 0.18);
            blob3Color = const Color(0xFF8EBEF7).withOpacity(isDark ? 0.12 : 0.15);
            break;
          case AppThemeType.sunset:
            gradientColors = isDark
                ? [const Color(0xFF231410), const Color(0xFF23101B), const Color(0xFF1C1E10)]
                : [const Color(0xFFFFF0E6), const Color(0xFFFFF3FA), const Color(0xFFF0F5D5)];
            blob1Color = const Color(0xFFF7A28E).withOpacity(isDark ? 0.12 : 0.18);
            blob2Color = const Color(0xFFF78EC8).withOpacity(isDark ? 0.10 : 0.18);
            blob3Color = const Color(0xFFDFE68E).withOpacity(isDark ? 0.10 : 0.15);
            break;
          case AppThemeType.nordic:
            gradientColors = isDark
                ? [const Color(0xFF0F1215), const Color(0xFF15181C), const Color(0xFF0E0F12)]
                : [const Color(0xFFECEFF1), const Color(0xFFF1F5F7), const Color(0xFFE0E6ED)];
            blob1Color = const Color(0xFF90A4AE).withOpacity(isDark ? 0.10 : 0.18);
            blob2Color = const Color(0xFFB0BEC5).withOpacity(isDark ? 0.08 : 0.18);
            blob3Color = const Color(0xFF78909C).withOpacity(isDark ? 0.08 : 0.15);
            break;
        }

        return Stack(
          children: [
            // Base gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Floating decorative circles in the background
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blob1Color,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blob2Color,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: -120,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blob3Color,
                ),
              ),
            ),
            // Main foreground content
            child,
          ],
        );
      },
    );
  }
}
