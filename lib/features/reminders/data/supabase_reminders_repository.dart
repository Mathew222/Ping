import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ping/features/reminders/domain/reminder.dart';
import 'package:ping/features/reminders/domain/recurrence_rule.dart';
import 'package:ping/features/reminders/data/i_reminders_repository.dart';

/// Repository for syncing reminders with Supabase
class SupabaseRemindersRepository implements IRemindersRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Watch all reminders for current user (real-time)
  /// Uses Supabase Realtime to automatically sync changes across devices
  Stream<List<Reminder>> watchReminders() {
    if (_currentUserId == null) {
      debugPrint('SupabaseRemindersRepository: No authenticated user');
      return Stream.error(Exception('User not authenticated'));
    }

    debugPrint(
        'SupabaseRemindersRepository: Setting up real-time stream for user $_currentUserId');

    // Use Supabase Realtime to watch for changes
    return _supabase
        .from('reminders')
        .stream(primaryKey: ['id'])
        .eq('user_id', _currentUserId!)
        .map((data) {
          debugPrint(
              'SupabaseRemindersRepository: Received ${data.length} reminders from stream');

          // Filter out soft-deleted reminders and convert to domain models
          final reminders = data
              .where((json) => json['deleted_at'] == null)
              .map((json) => _fromSupabase(json))
              .toList()
            ..sort((a, b) => a.triggerAt.compareTo(b.triggerAt));

          debugPrint(
              'SupabaseRemindersRepository: Emitting ${reminders.length} active reminders');
          return reminders;
        })
        .handleError((error) {
          debugPrint('SupabaseRemindersRepository: Stream error: $error');
        });
  }

  /// Get all reminders for current user
  Future<List<Reminder>> getReminders() async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('SupabaseRemindersRepository: Fetching reminders');
      final response = await _supabase
          .from('reminders')
          .select()
          .eq('user_id', _currentUserId!)
          .order('trigger_at');

      debugPrint(
          'SupabaseRemindersRepository: Fetched ${response.length} reminders');
      // Filter out soft-deleted reminders
      final reminders = (response as List)
          .where((json) => json['deleted_at'] == null)
          .map((json) => _fromSupabase(json))
          .toList();
      return reminders;
    } catch (e) {
      debugPrint('SupabaseRemindersRepository: Error fetching reminders: $e');
      rethrow;
    }
  }

  /// Get a single reminder by ID
  Future<Reminder?> getReminder(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('SupabaseRemindersRepository: Fetching reminder $id');
      final response = await _supabase
          .from('reminders')
          .select()
          .eq('id', id)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) {
        debugPrint('SupabaseRemindersRepository: Reminder $id not found');
        return null;
      }

      return _fromSupabase(response);
    } catch (e) {
      debugPrint('SupabaseRemindersRepository: Error fetching reminder: $e');
      rethrow;
    }
  }

  /// Create a new reminder
  Future<void> createReminder(Reminder reminder) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint(
          'SupabaseRemindersRepository: Creating reminder ${reminder.id}');
      final data = _toSupabase(reminder);
      data['user_id'] = _currentUserId!;

      await _supabase.from('reminders').insert(data);
      debugPrint('SupabaseRemindersRepository: Reminder created successfully');
      // Realtime stream will automatically emit the new reminder
    } catch (e) {
      debugPrint('SupabaseRemindersRepository: Error creating reminder: $e');
      rethrow;
    }
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint(
          'SupabaseRemindersRepository: Updating reminder ${reminder.id}');
      final data = _toSupabase(reminder);

      await _supabase
          .from('reminders')
          .update(data)
          .eq('id', reminder.id)
          .eq('user_id', _currentUserId!);

      debugPrint('SupabaseRemindersRepository: Reminder updated successfully');
      // Realtime stream will automatically emit the updated reminder
    } catch (e) {
      debugPrint('SupabaseRemindersRepository: Error updating reminder: $e');
      rethrow;
    }
  }

  /// Delete a reminder (soft delete)
  Future<void> deleteReminder(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('SupabaseRemindersRepository: Deleting reminder $id');
      await _supabase
          .from('reminders')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', _currentUserId!);

      debugPrint('SupabaseRemindersRepository: Reminder deleted successfully');
      // Realtime stream will automatically remove the deleted reminder
    } catch (e) {
      debugPrint('SupabaseRemindersRepository: Error deleting reminder: $e');
      rethrow;
    }
  }

  /// Convert Supabase JSON to Reminder
  Reminder _fromSupabase(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      triggerAt: DateTime.parse(json['trigger_at'] as String),
      originalTriggerAt: DateTime.parse(json['original_trigger_at'] as String),
      recurrenceRule: json['recurrence_rule'] != null
          ? RecurrenceRule.fromJson(
              json['recurrence_rule'] as Map<String, dynamic>)
          : null,
      isRecurring: json['is_recurring'] as bool? ?? false,
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReminderStatus.active,
      ),
      snoozedUntil: json['snoozed_until'] != null
          ? DateTime.parse(json['snoozed_until'] as String)
          : null,
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReminderPriority.normal,
      ),
    );
  }

  /// Convert Reminder to Supabase JSON
  Map<String, dynamic> _toSupabase(Reminder reminder) {
    return {
      'id': reminder.id,
      'title': reminder.title,
      'description': reminder.body,
      'trigger_at': reminder.triggerAt.toIso8601String(),
      'original_trigger_at': reminder.originalTriggerAt.toIso8601String(),
      'status': reminder.status.name,
      'priority': reminder.priority.name,
      'is_recurring': reminder.isRecurring,
      'recurrence_rule': reminder.recurrenceRule?.toJson(),
      'snoozed_until': reminder.snoozedUntil?.toIso8601String(),
      'version': reminder.version,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get all active reminders
  @override
  Future<List<Reminder>> getActiveReminders() async {
    final allReminders = await getReminders();
    return allReminders
        .where((r) => r.status == ReminderStatus.active)
        .toList();
  }

  /// Get completed reminders (history)
  @override
  Future<List<Reminder>> getCompletedReminders() async {
    final allReminders = await getReminders();
    return allReminders
        .where((r) => r.status == ReminderStatus.completed)
        .toList();
  }
}
