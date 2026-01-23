import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping/app/router.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';

/// Main Ping application
class PingApp extends ConsumerWidget {
  const PingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Keep the reminder actions provider alive to handle notification actions
    ref.watch(reminderActionsProvider);

    return MaterialApp.router(
      title: 'Ping',
      debugShowCheckedModeBanner: false,
      theme: PingTheme.lightTheme,
      darkTheme: PingTheme.darkTheme,
      themeMode: ThemeMode.dark, // Temporarily forced to dark for testing
      routerConfig: router,
    );
  }
}
