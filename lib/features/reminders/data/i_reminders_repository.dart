import 'package:ping/features/reminders/domain/reminder.dart';

/// Abstract interface for reminders repository
/// Implemented by both local and Supabase repositories
abstract class IRemindersRepository {
  /// Watch all reminders as a stream
  Stream<List<Reminder>> watchReminders();

  /// Get a single reminder by ID
  Future<Reminder?> getReminder(String id);

  /// Create a new reminder
  Future<void> createReminder(Reminder reminder);

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder);

  /// Delete a reminder
  Future<void> deleteReminder(String id);

  /// Get all active reminders
  Future<List<Reminder>> getActiveReminders();

  /// Get completed reminders (history)
  Future<List<Reminder>> getCompletedReminders();
}
