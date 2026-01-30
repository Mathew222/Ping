import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:ping/app/theme/ping_theme.dart';

/// Optimized animated splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Generate fewer particles for better performance
    for (int i = 0; i < 8; i++) {
      _particles.add(Particle());
    }

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PingTheme.primaryRed,
              PingTheme.primaryRed.withBlue(180),
              PingTheme.textSecondary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Simplified particles
            ...(_particles.map((particle) =>
                AnimatedParticle(particle: particle, controller: _controller))),

            // Logo and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      size: 50,
                      color: PingTheme.primaryRed,
                    ),
                  )
                      .animate(controller: _controller)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // App name
                  Text(
                    'Ping',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _controller)
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Never miss a moment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.95),
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate(controller: _controller)
                      .fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle data
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;

  Particle()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        size = math.Random().nextDouble() * 4 + 2,
        speed = math.Random().nextDouble() * 0.3 + 0.2;
}

/// Optimized animated particle
class AnimatedParticle extends StatelessWidget {
  final Particle particle;
  final AnimationController controller;

  const AnimatedParticle({
    super.key,
    required this.particle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final yPos = particle.y * size.height -
            (progress * size.height * particle.speed);

        return Positioned(
          left: particle.x * size.width,
          top: yPos % size.height,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
