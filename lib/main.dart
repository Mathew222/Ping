import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/app/app.dart';
import 'package:ping/core/notifications/notification_service.dart';
import 'package:ping/core/config/supabase_config.dart';
import 'package:ping/core/sounds/sound_service.dart';
import 'package:ping/core/monetization/revenue_cat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
    debugPrint('Please configure Supabase credentials in supabase_config.dart');
  }

  // Initialize RevenueCat
  try {
    await RevenueCatService.instance.initialize();
    debugPrint('RevenueCat initialized successfully');
  } catch (e) {
    debugPrint('RevenueCat initialization error: $e');
    debugPrint(
        'Please configure RevenueCat API keys in revenue_cat_config.dart');
  }

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Load and apply saved notification sound
  final soundService = SoundService();
  final savedSound = await soundService.getSelectedSound();
  NotificationService.instance.setNotificationSound(savedSound);
  debugPrint('Loaded notification sound: ${savedSound.displayName}');

  // TODO: Initialize Firebase
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: PingApp(),
    ),
  );
}
