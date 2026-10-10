import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireworksCelebration extends StatefulWidget {
  final String winnerName;
  final VoidCallback onFinished;

  const FireworksCelebration({
    Key? key,
    required this.winnerName,
    required this.onFinished,
  }) : super(key: key);

  @override
  State<FireworksCelebration> createState() => _FireworksCelebrationState();
}

class _FireworksCelebrationState extends State<FireworksCelebration> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<Explosion> _explosions = [];
  final Random _random = Random();
  double _timeElapsed = 0.0;
  bool _isFinished = false;
  Size _screenSize = const Size(400, 800);
  
  // Soft pastel color palette for fireworks
  final List<Color> _fireworkColors = [
    const Color(0xFF8E9DF7), // Soft Lavender
    const Color(0xFFF78EAE), // Soft Rose
    const Color(0xFF8EF7CD), // Soft Mint
    const Color(0xFFF7BD8E), // Soft Orange
    const Color(0xFFB38EF7), // Soft Purple
    const Color(0xFFFFE082), // Soft Amber/Gold
  ];

  @override
  void initState() {
    super.initState();
    // Start ticker for smooth 60fps physics rendering
    _ticker = createTicker(_updatePhysics);
    _ticker.start();
    
    // Spawn initial fireworks after layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _spawnFirework();
        _spawnFirework();
      }
    });
  }

  @override
  void dispose() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _ticker.dispose();
    super.dispose();
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    if (_ticker.isActive) {
      _ticker.stop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  void _updatePhysics(Duration elapsed) {
    if (!mounted || _isFinished) return;
    
    setState(() {
      _timeElapsed += 0.016; // Approx 60fps tick

      // 1. Update existing particles
      for (int i = _explosions.length - 1; i >= 0; i--) {
        final explosion = _explosions[i];
        explosion.update();
        if (explosion.isDead) {
          _explosions.removeAt(i);
        }
      }

      // 2. Periodically spawn new fireworks (every ~0.6 seconds)
      if (_random.nextDouble() < 0.03 && _timeElapsed < 4.5) {
        _spawnFirework();
      }

      // 3. Auto finish after 5.5 seconds of fireworks show
      if (_timeElapsed >= 5.5) {
        _finish();
      }
    });
  }

  void _spawnFirework() {
    final double x = _random.nextDouble() * _screenSize.width;
    final double y = 100.0 + _random.nextDouble() * (_screenSize.height * 0.4);
    final color = _fireworkColors[_random.nextInt(_fireworkColors.length)];
    
    _explosions.add(Explosion(
      x: x,
      y: y,
      color: color,
      random: _random,
    ));
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.sizeOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finish, // Tap anywhere to skip fireworks and see scoreboard
      child: Stack(
        children: [
          // Background black-blue celebratory gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A), // Dark slate
                  Color(0xFF1E1B4B), // Very dark purple/indigo
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Fireworks particles canvas
          CustomPaint(
            size: Size.infinite,
            painter: FireworksPainter(explosions: _explosions),
          ),
          
          // Congratulations and Winner Announcement overlay
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🏆 TEBRİKLER 🏆',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE082),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Trophy Big Emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    builder: (context, val, child) {
                      return Transform.scale(
                        scale: val,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFE082).withOpacity(0.5), width: 2),
                      ),
                      child: const Center(
                        child: Text('👑', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'OYUNUN KAZANANI:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Winner Name with smooth animated scale and glow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      widget.winnerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFF8E9DF7),
                            blurRadius: 20,
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            color: Color(0xFFF78EAE),
                            blurRadius: 40,
                            offset: Offset(0, 0),
                          ),
                        ],
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.touch_app_rounded, color: Colors.white60, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Sıralamayı görmek için dokunun',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Explosion {
  final double x;
  final double y;
  final Color color;
  final List<Particle> particles = [];
  final Random random;

  Explosion({
    required this.x,
    required this.y,
    required this.color,
    required this.random,
  }) {
    // Generate ~60 particles per firework explosion
    final int count = 50 + random.nextInt(20);
    for (int i = 0; i < count; i++) {
      final double angle = random.nextDouble() * 2 * pi;
      final double speed = 1.5 + random.nextDouble() * 5.0;
      particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: color,
        size: 2.0 + random.nextDouble() * 3.5,
        decay: 0.01 + random.nextDouble() * 0.02,
      ));
    }
  }

  bool get isDead => particles.isEmpty;

  void update() {
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.update();
      if (p.alpha <= 0) {
        particles.removeAt(i);
      }
    }
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  final double size;
  double alpha = 1.0;
  final double decay;
  
  static const double gravity = 0.12;
  static const double drag = 0.96;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.decay,
  });

  void update() {
    x += vx;
    y += vy;
    
    // Slow down speed gradually
    vx *= drag;
    vy *= drag;
    
    // Apply gravity
    vy += gravity;
    
    // Fade out
    alpha -= decay;
    if (alpha < 0) alpha = 0;
  }
}

class FireworksPainter extends CustomPainter {
  final List<Explosion> explosions;

  FireworksPainter({required this.explosions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final explosion in explosions) {
      for (final p in explosion.particles) {
        paint.color = p.color.withOpacity(p.alpha);
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
