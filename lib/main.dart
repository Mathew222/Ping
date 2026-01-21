import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/app/app.dart';
import 'package:ping/core/notifications/notification_service.dart';
import 'package:ping/core/config/supabase_config.dart';

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

  // Initialize notification service
  await NotificationService.instance.initialize();

  // TODO: Initialize Firebase
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: PingApp(),
    ),
  );
}
