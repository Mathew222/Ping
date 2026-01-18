import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ping/features/reminders/presentation/screens/create_reminder_screen.dart';
import 'package:ping/features/reminders/presentation/screens/edit_reminder_screen.dart';
import 'package:ping/features/history/presentation/screens/history_screen.dart';
import 'package:ping/features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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

class _BottomNavBarWithFAB extends StatelessWidget {
  const _BottomNavBarWithFAB();

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
          
          // Create FAB (centered)
          GestureDetector(
            onTap: () => context.pushNamed('create'),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PingTheme.primaryMint,
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
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? PingTheme.cardWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected ? [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(30),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ] : null,
        ),
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? PingTheme.textPrimary : PingTheme.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
