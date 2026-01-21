import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ping/features/reminders/presentation/screens/create_reminder_screen.dart';
import 'package:ping/features/reminders/presentation/screens/edit_reminder_screen.dart';
import 'package:ping/features/history/presentation/screens/history_screen.dart';
import 'package:ping/features/settings/presentation/screens/settings_screen.dart';
import 'package:ping/features/splash/splash_screen.dart';
import 'package:ping/features/auth/presentation/screens/login_screen.dart';
import 'package:ping/features/auth/presentation/screens/signup_screen.dart';
import 'package:ping/features/auth/presentation/providers/auth_provider.dart';
import 'package:ping/features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Skip auth check for splash, login, and signup
      final publicRoutes = ['/splash', '/login', '/signup'];
      if (publicRoutes.contains(state.uri.path)) {
        return null;
      }

      // Check if user is authenticated
      final isAuthenticated = ref.read(isAuthenticatedProvider);

      // Redirect to login if not authenticated
      if (!isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'reminders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/create',
        name: 'create',
        builder: (context, state) => const CreateReminderScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditReminderScreen(reminderId: id);
        },
      ),
    ],
  );
});

/// Main app shell with centered FAB bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PingTheme.bgLight,
      body: child,
      extendBody: true,
      bottomNavigationBar: const _BottomNavBarWithFAB(),
    );
  }
}

class _BottomNavBarWithFAB extends StatefulWidget {
  const _BottomNavBarWithFAB();

  @override
  State<_BottomNavBarWithFAB> createState() => _BottomNavBarWithFABState();
}

class _BottomNavBarWithFABState extends State<_BottomNavBarWithFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location == '/history') currentIndex = 1;
    if (location == '/settings') currentIndex = 2;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PingTheme.bgLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: PingTheme.shadowDark.withAlpha(60),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home button
          _NavButton(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            isSelected: currentIndex == 0,
            onTap: () => context.goNamed('reminders'),
          ),

          // Create FAB (centered) with pulse animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.05);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.pushNamed('create');
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PingTheme.primaryMint,
                      PingTheme.primaryMint.withGreen(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: PingTheme.primaryMint.withAlpha(100),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
            ),
          ),

          // Settings button
          _NavButton(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            isSelected: currentIndex == 2,
            onTap: () => context.goNamed('settings'),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? PingTheme.cardWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PingTheme.shadowDark.withAlpha(30),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            isSelected ? selectedIcon : icon,
            key: ValueKey(isSelected),
            color: isSelected ? PingTheme.textPrimary : PingTheme.textSecondary,
            size: 24,
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        );
  }
}
