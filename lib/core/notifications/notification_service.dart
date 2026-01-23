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

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Remember last snooze duration for quick snooze
  int _lastSnoozeDuration = 10;
  int get lastSnoozeDuration => _lastSnoozeDuration;
  set lastSnoozeDuration(int value) => _lastSnoozeDuration = value;

  // Callback when user interacts with notification
  Function(String reminderId, String action, int? snoozeDuration)?
      onActionReceived;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('NotificationService: Web platform - notifications disabled');
      return;
    }

    // Initialize timezone
    tz_data.initializeTimeZones();

    debugPrint(
        'NotificationService: Initializing for ${Platform.operatingSystem}');

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      debugPrint(
          'NotificationService: Web - would schedule "${reminder.title}"');
      return;
    }

    debugPrint(
        'NotificationService: Scheduling "${reminder.title}" for ${reminder.triggerAt}');

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
      payload: '${reminder.id}|${reminder.lastSnoozeDuration ?? ""}',
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
      payload: '${reminder.id}|${reminder.lastSnoozeDuration ?? ""}',
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
    // Use the reminder's last snooze duration, or default to 10 minutes
    final snoozeDuration = reminder.lastSnoozeDuration ?? _lastSnoozeDuration;

    // Android notification with action buttons
    final androidDetails = AndroidNotificationDetails(
      'ping_reminders',
      'Ping Reminders',
      channelDescription: 'Reminder notifications from Ping',
      importance: Importance.max, // Changed to max for better visibility
      priority: Priority.max, // Changed to max
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      // Remove styleInformation to use default style which shows actions better
      fullScreenIntent: true, // Show as heads-up notification
      actions: [
        const AndroidNotificationAction(
          'complete',
          'Done ✓',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze',
          'Snooze $snoozeDuration min',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze_custom',
          'Custom...',
          showsUserInterface: true,
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
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('NotificationService: Notification Response Received');
    debugPrint('  Action ID: ${response.actionId ?? "TAP (no action)"}');
    debugPrint('  Payload: ${response.payload}');
    debugPrint('  Input: ${response.input}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Parse payload: "id|duration"
    final parts = response.payload?.split('|') ?? [];
    final reminderId = parts.isNotEmpty ? parts[0] : null;
    final payloadDuration =
        parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1]) : null;

    if (reminderId == null) {
      debugPrint('NotificationService: No payload found, ignoring');
      return;
    }

    switch (response.actionId) {
      case 'complete':
        debugPrint('NotificationService: Calling COMPLETE action');
        onActionReceived?.call(reminderId, 'COMPLETE', null);
        // Auto-dismiss notification
        _plugin.cancel(reminderId.hashCode);
        debugPrint('NotificationService: Auto-dismissed notification');
        break;
      case 'snooze':
        // Use payload duration if available, otherwise default
        final duration = payloadDuration ?? _lastSnoozeDuration;
        debugPrint(
            'NotificationService: Calling SNOOZE_QUICK action with $duration minutes');
        onActionReceived?.call(reminderId, 'SNOOZE_QUICK', duration);
        // Auto-dismiss and show feedback
        _plugin.cancel(reminderId.hashCode);
        _showSnoozeConfirmation(reminderId, duration);
        debugPrint(
            'NotificationService: Auto-dismissed and showing snooze feedback');
        break;
      case 'snooze_custom':
        debugPrint('NotificationService: Calling SNOOZE_CUSTOM action');
        onActionReceived?.call(reminderId, 'SNOOZE_CUSTOM', null);
        // Auto-dismiss notification
        _plugin.cancel(reminderId.hashCode);
        debugPrint('NotificationService: Auto-dismissed notification');
        break;
      default:
        // Tapped on notification body - open app
        debugPrint(
            'NotificationService: Calling TAP action (notification body tapped)');
        onActionReceived?.call(reminderId, 'TAP', null);
    }
  }

  /// Show snooze confirmation notification
  Future<void> _showSnoozeConfirmation(String reminderId, int minutes) async {
    if (kIsWeb) return;

    debugPrint(
        'NotificationService: Showing snooze confirmation for $minutes minutes');

    await _plugin.show(
      reminderId.hashCode + 999999, // Different ID for feedback notification
      'Reminder Snoozed',
      'Snoozed for ${CustomSnoozePicker.formatDuration(minutes)}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'ping_reminders',
          'Ping Reminders',
          channelDescription: 'Reminder notifications from Ping',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          autoCancel: true,
          timeoutAfter: 3000, // Auto-dismiss after 3 seconds
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
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
