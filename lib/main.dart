import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping/app/app.dart';
import 'package:ping/core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
