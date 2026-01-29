import 'package:flutter/material.dart';
import 'package:ping/app/theme/ping_theme.dart';

/// Premium badge widget to indicate premium features
class PremiumBadge extends StatelessWidget {
  final double size;
  final bool showText;

  const PremiumBadge({
    super.key,
    this.size = 20,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PingTheme.primaryRed,
              PingTheme.primaryRed.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium,
              size: size * 0.8,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      Icons.workspace_premium,
      size: size,
      color: PingTheme.primaryRed,
    );
  }
}

/// Premium feature lock overlay
class PremiumLockOverlay extends StatelessWidget {
  final VoidCallback onTap;
  final String? message;

  const PremiumLockOverlay({
    super.key,
    required this.onTap,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              if (message != null)
                Text(
                  message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: PingTheme.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
