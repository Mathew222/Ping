import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ping/features/reminders/domain/reminder.dart';

/// Repository for managing reminders
/// 
/// Uses singleton pattern to maintain state across the app.
/// Currently uses in-memory storage for development.
/// TODO: Implement Drift database and Firebase sync
class RemindersRepository {
  // Singleton instance
  static final RemindersRepository _instance = RemindersRepository._internal();
  factory RemindersRepository() => _instance;
  RemindersRepository._internal();
  
  // In-memory storage
  final Map<String, Reminder> _reminders = {};
  final _controller = StreamController<List<Reminder>>.broadcast();

  /// Watch all reminders as a stream
  Stream<List<Reminder>> watchReminders() {
    // Emit current state immediately
    Future.microtask(() => _emit());
    return _controller.stream;
  }

  /// Get a single reminder by ID
  Future<Reminder?> getReminder(String id) async {
    return _reminders[id];
  }

  /// Create a new reminder
  Future<void> createReminder(Reminder reminder) async {
    debugPrint('RemindersRepository: Creating reminder "${reminder.title}" (${reminder.id})');
    _reminders[reminder.id] = reminder;
    _emit();
    debugPrint('RemindersRepository: Now have ${_reminders.length} reminders');
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    debugPrint('RemindersRepository: Updating reminder "${reminder.title}"');
    _reminders[reminder.id] = reminder;
    _emit();
  }

  /// Delete a reminder
  Future<void> deleteReminder(String id) async {
    debugPrint('RemindersRepository: Deleting reminder $id');
    _reminders.remove(id);
    _emit();
  }

  /// Get all reminders
  List<Reminder> get allReminders => _reminders.values.toList();

  /// Get all active reminders
  Future<List<Reminder>> getActiveReminders() async {
    return _reminders.values
      .where((r) => r.status == ReminderStatus.active)
      .toList();
  }

  /// Get completed reminders (history)
  Future<List<Reminder>> getCompletedReminders() async {
    return _reminders.values
      .where((r) => r.status == ReminderStatus.completed)
      .toList();
  }

  void _emit() {
    final list = _reminders.values.toList();
    debugPrint('RemindersRepository: Emitting ${list.length} reminders');
    _controller.add(list);
  }

  void dispose() {
    _controller.close();
  }
}
