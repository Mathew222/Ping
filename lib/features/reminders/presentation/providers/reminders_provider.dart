import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ping/features/reminders/domain/reminder.dart';
import 'package:ping/features/reminders/data/i_reminders_repository.dart';
import 'package:ping/features/reminders/data/reminders_repository.dart';
import 'package:ping/features/reminders/data/supabase_reminders_repository.dart';
import 'package:ping/features/auth/presentation/providers/auth_provider.dart';
import 'package:ping/core/notifications/notification_service.dart';
import 'package:ping/core/notifications/snooze_picker.dart';
import 'package:ping/app/router.dart' show navigatorKeyProvider;

/// Provider for the reminders repository
/// Uses Supabase when authenticated, falls back to local storage
final remindersRepositoryProvider = Provider<IRemindersRepository>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  if (isAuthenticated) {
    debugPrint('RemindersProvider: Using Supabase repository');
    return SupabaseRemindersRepository();
  }

  debugPrint('RemindersProvider: Using local repository');
  return RemindersRepository();
});

/// Provider for all active reminders
final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repository = ref.watch(remindersRepositoryProvider);
  return repository.watchReminders();
});

/// Provider for upcoming reminders (next 24 hours)
final upcomingRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return reminders
        .where((r) =>
            r.status == ReminderStatus.active && r.triggerAt.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
  });
});

/// Provider for overdue reminders
final overdueRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    final now = DateTime.now();
    return reminders
        .where((r) =>
            r.status == ReminderStatus.active && r.triggerAt.isBefore(now))
        .toList()
      ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
  });
});

/// Provider for snoozed reminders
final snoozedRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    return reminders.where((r) => r.status == ReminderStatus.snoozed).toList()
      ..sort((a, b) => (a.snoozedUntil ?? a.triggerAt)
          .compareTo(b.snoozedUntil ?? b.triggerAt));
  });
});

/// Provider for a single reminder by ID
final reminderByIdProvider =
    Provider.family<AsyncValue<Reminder?>, String>((ref, id) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  });
});

/// Provider for reminders on a specific date
final remindersByDateProvider =
    Provider.family<AsyncValue<List<Reminder>>, DateTime>((ref, date) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    return reminders.where((r) {
      final reminderDate = r.triggerAt;
      return reminderDate.year == date.year &&
          reminderDate.month == date.month &&
          reminderDate.day == date.day;
    }).toList()
      ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
  });
});

/// Provider for reminder count on a specific date
final reminderCountByDateProvider =
    Provider.family<AsyncValue<int>, DateTime>((ref, date) {
  final remindersAsync = ref.watch(remindersByDateProvider(date));
  return remindersAsync.whenData((reminders) => reminders.length);
});

/// Provider for dates with reminders in a given month
final datesWithRemindersProvider =
    Provider.family<AsyncValue<Set<DateTime>>, DateTime>((ref, month) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.whenData((reminders) {
    final dates = <DateTime>{};
    for (final reminder in reminders) {
      final date = reminder.triggerAt;
      if (date.year == month.year && date.month == month.month) {
        dates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return dates;
  });
});

/// Notifier for reminder actions
class ReminderActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IRemindersRepository _repository;
  final NotificationService _notifications;
  final GlobalKey<NavigatorState> _navigatorKey;

  ReminderActionsNotifier(
    this._repository,
    this._notifications,
    this._navigatorKey,
  ) : super(const AsyncValue.data(null)) {
    // Listen to notification actions
    _notifications.onActionReceived = _handleNotificationAction;
  }

  /// Create a new reminder
  Future<void> createReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createReminder(reminder);
      await _notifications.scheduleReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Convenience shorthand for createReminder
  Future<void> create(Reminder reminder) => createReminder(reminder);

  /// Convenience shorthand for completeReminder
  Future<void> complete(String id) => completeReminder(id);

  /// Convenience shorthand for snoozeReminder
  Future<void> snooze(String id, Duration duration) =>
      snoozeReminder(id, duration);

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      // Cancel old notification FIRST to prevent duplicates
      await _notifications.cancelReminder(reminder.id);
      await _repository.updateReminder(reminder);
      await _notifications.scheduleReminder(reminder);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Snooze a reminder
  Future<void> snoozeReminder(String id, Duration duration) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('ReminderActionsNotifier: snoozeReminder called for $id');
    debugPrint(
        'ReminderActionsNotifier: Snooze duration: ${duration.inMinutes} minutes');
    state = const AsyncValue.loading();
    try {
      final reminder = await _repository.getReminder(id);
      debugPrint(
          'ReminderActionsNotifier: Retrieved reminder: ${reminder?.title}');

      if (reminder != null) {
        debugPrint(
            'ReminderActionsNotifier: Current trigger time: ${reminder.triggerAt}');
        debugPrint(
            'ReminderActionsNotifier: Current status: ${reminder.status}');

        // Cancel old notification FIRST to prevent duplicates
        await _notifications.cancelReminder(id);
        debugPrint('ReminderActionsNotifier: Cancelled old notification');

        final snoozed = reminder.snooze(duration);
        debugPrint(
            'ReminderActionsNotifier: Snoozed until: ${snoozed.snoozedUntil}');
        debugPrint(
            'ReminderActionsNotifier: New trigger time: ${snoozed.triggerAt}');
        debugPrint('ReminderActionsNotifier: New status: ${snoozed.status}');

        await _repository.updateReminder(snoozed);
        debugPrint('ReminderActionsNotifier: Updated reminder in repository');

        await _notifications.scheduleReminder(snoozed);
        debugPrint('ReminderActionsNotifier: Scheduled new notification');
      } else {
        debugPrint('ReminderActionsNotifier: Reminder not found!');
      }
      state = const AsyncValue.data(null);
      debugPrint(
          'ReminderActionsNotifier: snoozeReminder completed successfully');
    } catch (e, st) {
      debugPrint('ReminderActionsNotifier: Error snoozing reminder: $e');
      debugPrint('Stack trace: $st');
      state = AsyncValue.error(e, st);
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Complete a reminder
  Future<void> completeReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      final reminder = await _repository.getReminder(id);
      if (reminder != null) {
        final completed = reminder.complete();
        await _repository.updateReminder(completed);
        await _notifications.cancelReminder(id);

        // If recurring, schedule next occurrence
        if (completed.isRecurring &&
            completed.status == ReminderStatus.active) {
          await _notifications.scheduleReminder(completed);
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Skip a reminder occurrence
  Future<void> skipReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      final reminder = await _repository.getReminder(id);
      if (reminder != null) {
        final skipped = reminder.skip();
        await _repository.updateReminder(skipped);
        await _notifications.cancelReminder(id);

        // If recurring, schedule next occurrence
        if (skipped.isRecurring && skipped.status == ReminderStatus.active) {
          await _notifications.scheduleReminder(skipped);
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Stop a recurring reminder permanently
  Future<void> stopRecurring(String id) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('ReminderActionsNotifier: stopRecurring called for $id');
    state = const AsyncValue.loading();
    try {
      final reminder = await _repository.getReminder(id);
      debugPrint(
          'ReminderActionsNotifier: Retrieved reminder: ${reminder?.title}');
      debugPrint(
          'ReminderActionsNotifier: Is recurring: ${reminder?.isRecurring}');

      if (reminder != null && reminder.isRecurring) {
        debugPrint('ReminderActionsNotifier: Stopping recurring reminder');
        final stopped = reminder.stopRecurring();
        debugPrint(
            'ReminderActionsNotifier: Stopped reminder status: ${stopped.status}');
        debugPrint(
            'ReminderActionsNotifier: Stopped reminder isRecurring: ${stopped.isRecurring}');

        await _notifications.cancelReminder(id);
        debugPrint('ReminderActionsNotifier: Cancelled notification');

        await _repository.updateReminder(stopped);
        debugPrint('ReminderActionsNotifier: Updated reminder in repository');
      } else {
        debugPrint(
            'ReminderActionsNotifier: Reminder not found or not recurring');
      }
      state = const AsyncValue.data(null);
      debugPrint(
          'ReminderActionsNotifier: stopRecurring completed successfully');
    } catch (e, st) {
      debugPrint('ReminderActionsNotifier: Error stopping recurring: $e');
      debugPrint('Stack trace: $st');
      state = AsyncValue.error(e, st);
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Delete a reminder
  Future<void> deleteReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      // Cancel notification FIRST to prevent rescheduling
      await _notifications.cancelReminder(id);
      await _repository.deleteReminder(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Handle notification action callback
  Future<void> _handleNotificationAction(
      String reminderId, String action, int? snoozeDuration) async {
    debugPrint(
        'ReminderActionsNotifier: Handling notification action: $action for reminder $reminderId');

    try {
      switch (action) {
        case 'COMPLETE':
          debugPrint(
              'ReminderActionsNotifier: Completing reminder $reminderId');
          await completeReminder(reminderId);
          break;
        case 'SNOOZE_QUICK':
          final duration = Duration(minutes: snoozeDuration ?? 10);
          debugPrint(
              'ReminderActionsNotifier: Snoozing reminder $reminderId for ${duration.inMinutes} minutes');
          await snoozeReminder(reminderId, duration);
          break;
        case 'SNOOZE_CUSTOM':
          debugPrint('ReminderActionsNotifier: Opening custom snooze picker');
          await _handleCustomSnooze(reminderId);
          break;
        case 'SKIP':
          debugPrint('ReminderActionsNotifier: Skipping reminder $reminderId');
          await skipReminder(reminderId);
          break;
        default:
          debugPrint('ReminderActionsNotifier: Unknown action: $action');
      }
    } catch (e, st) {
      debugPrint(
          'ReminderActionsNotifier: Error handling notification action: $e');
      debugPrint('Stack trace: $st');
    }
  }

  /// Handle custom snooze action from notification
  Future<void> _handleCustomSnooze(String reminderId) async {
    debugPrint(
        'ReminderActionsNotifier: _handleCustomSnooze called for $reminderId');

    try {
      // Get the reminder to show its title
      final reminder = await _repository.getReminder(reminderId);
      if (reminder == null) {
        debugPrint(
            'ReminderActionsNotifier: Reminder not found for custom snooze');
        return;
      }

      // Get navigator context
      final context = _navigatorKey.currentContext;
      if (context == null) {
        debugPrint('ReminderActionsNotifier: No navigator context available');
        return;
      }

      debugPrint('ReminderActionsNotifier: Showing custom snooze sheet');

      // Show custom snooze sheet
      final minutes = await CustomSnoozeSheet.show(
        context,
        reminderId: reminderId,
        reminderTitle: reminder.title,
      );

      if (minutes != null) {
        debugPrint('ReminderActionsNotifier: User selected $minutes minutes');
        await snoozeReminder(reminderId, Duration(minutes: minutes));
      } else {
        debugPrint('ReminderActionsNotifier: User canceled custom snooze');
      }
    } catch (e, st) {
      debugPrint('ReminderActionsNotifier: Error in _handleCustomSnooze: $e');
      debugPrint('Stack trace: $st');
    }
  }
}

/// Provider for reminder actions
final reminderActionsProvider =
    StateNotifierProvider<ReminderActionsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(remindersRepositoryProvider);
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return ReminderActionsNotifier(
    repository,
    NotificationService.instance,
    navigatorKey,
  );
});
