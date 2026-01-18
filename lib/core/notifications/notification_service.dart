import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ping/features/reminders/domain/reminder.dart';

/// NotificationService - Full implementation with Android/iOS notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  // Remember last snooze duration for quick snooze
  int _lastSnoozeDuration = 10;
  int get lastSnoozeDuration => _lastSnoozeDuration;
  set lastSnoozeDuration(int value) => _lastSnoozeDuration = value;
  
  // Callback when user interacts with notification
  Function(String reminderId, String action, int? snoozeDuration)? onActionReceived;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('NotificationService: Web platform - notifications disabled');
      return;
    }

    // Initialize timezone
    tz_data.initializeTimeZones();
    
    debugPrint('NotificationService: Initializing for ${Platform.operatingSystem}');
    
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundResponse,
    );
    
    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
    
    // Create notification channel for Android
    await _createNotificationChannel();
    
    debugPrint('NotificationService: Initialized successfully');
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'ping_reminders',
      'Ping Reminders',
      description: 'Reminder notifications from Ping',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      debugPrint('NotificationService: Web - would schedule "${reminder.title}"');
      return;
    }

    debugPrint('NotificationService: Scheduling "${reminder.title}" for ${reminder.triggerAt}');
    
    final scheduledTime = tz.TZDateTime.from(reminder.triggerAt, tz.local);
    
    // If time is in the past, show immediately
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      await showReminder(reminder);
      return;
    }

    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.body ?? 'Tap to view',
      scheduledTime,
      _getNotificationDetails(reminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: reminder.id,
    );
  }

  /// Show an immediate notification
  Future<void> showReminder(Reminder reminder) async {
    if (kIsWeb) return;
    
    debugPrint('NotificationService: Showing "${reminder.title}" immediately');
    
    await _plugin.show(
      reminder.id.hashCode,
      reminder.title,
      reminder.body ?? 'Tap to view',
      _getNotificationDetails(reminder),
      payload: reminder.id,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelReminder(String reminderId) async {
    if (kIsWeb) return;
    await _plugin.cancel(reminderId.hashCode);
    debugPrint('NotificationService: Cancelled $reminderId');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  NotificationDetails _getNotificationDetails(Reminder reminder) {
    // Android notification with action buttons
    final androidDetails = AndroidNotificationDetails(
      'ping_reminders',
      'Ping Reminders',
      channelDescription: 'Reminder notifications from Ping',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      actions: [
        const AndroidNotificationAction(
          'complete',
          'Done ✓',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'snooze',
          'Snooze $_lastSnoozeDuration min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_custom',
          'Custom...',
          showsUserInterface: true, // Opens app for custom snooze
        ),
      ],
    );
    
    // iOS notification
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'reminder_category',
    );
    
    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Response - action: ${response.actionId}, payload: ${response.payload}');
    
    final reminderId = response.payload;
    if (reminderId == null) return;
    
    switch (response.actionId) {
      case 'complete':
        onActionReceived?.call(reminderId, 'COMPLETE', null);
        break;
      case 'snooze':
        onActionReceived?.call(reminderId, 'SNOOZE_QUICK', _lastSnoozeDuration);
        break;
      case 'snooze_custom':
        onActionReceived?.call(reminderId, 'SNOOZE_CUSTOM', null);
        break;
      default:
        // Tapped on notification body - open app
        onActionReceived?.call(reminderId, 'TAP', null);
    }
  }
}

// Background handler must be top-level function
@pragma('vm:entry-point')
void _handleBackgroundResponse(NotificationResponse response) {
  debugPrint('NotificationService: Background response - ${response.actionId}');
  // Background actions are handled in the foreground when app opens
}

/// Helper class for snooze duration formatting
class CustomSnoozePicker {
  static const List<int> quickOptions = [5, 10, 15, 20, 30, 45, 60];
  
  static int? parseInput(String input) {
    final trimmed = input.trim().toLowerCase();
    final asNumber = int.tryParse(trimmed);
    if (asNumber != null && asNumber > 0 && asNumber <= 1440) {
      return asNumber;
    }
    return null;
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60} hours';
    } else {
      return '${minutes ~/ 60}h ${minutes % 60}m';
    }
  }
}
