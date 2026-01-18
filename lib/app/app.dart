import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/app/router.dart';

class PingApp extends ConsumerWidget {
  const PingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    // Platform-adaptive theming
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoApp.router(
        title: 'Ping',
        theme: PingTheme.cupertinoTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
    }
    
    return MaterialApp.router(
      title: 'Ping',
      theme: PingTheme.lightTheme,
      darkTheme: PingTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
