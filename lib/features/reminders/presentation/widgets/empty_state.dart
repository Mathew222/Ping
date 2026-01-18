import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';

/// Neumorphic empty state placeholder widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: PingTheme.primaryMint.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: PingTheme.primaryMint,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(end: 1.05, duration: 2000.ms, curve: Curves.easeInOut),
            
            const SizedBox(height: 32),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: PingTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: PingTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
