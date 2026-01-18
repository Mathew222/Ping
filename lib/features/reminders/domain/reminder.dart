import 'package:uuid/uuid.dart';
import 'package:ping/features/reminders/domain/recurrence_rule.dart';

/// Reminder status enum
enum ReminderStatus {
  active,
  snoozed,
  completed,
  skipped,
}

/// Priority levels for reminders
enum ReminderPriority {
  low,
  normal,
  high,
}

/// Sync status for offline-first architecture
enum SyncStatus {
  synced,
  pending,
  conflict,
}

/// Core Reminder entity
/// 
/// This is the central data model for the entire app.
/// Reminders are server-authoritative with optimistic local updates.
class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? body;
  
  // Timing
  final DateTime createdAt;
  final DateTime triggerAt;
  final DateTime originalTriggerAt;
  
  // Recurrence
  final RecurrenceRule? recurrenceRule;
  final bool isRecurring;
  
  // State
  final ReminderStatus status;
  final DateTime? snoozedUntil;
  final int? lastSnoozeDuration; // Minutes - remembered for quick snooze
  
  // Sync
  final int version;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  
  // Metadata
  final String? profileId;
  final List<String> tags;
  final ReminderPriority priority;

  /// Simple constructor with auto-generated ID and timestamps
  Reminder({
    String? id,
    String? userId,
    required this.title,
    this.body,
    DateTime? createdAt,
    required this.triggerAt,
    DateTime? originalTriggerAt,
    this.recurrenceRule,
    bool? isRecurring,
    this.status = ReminderStatus.active,
    this.snoozedUntil,
    this.lastSnoozeDuration,
    this.version = 1,
    DateTime? updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.profileId,
    this.tags = const [],
    this.priority = ReminderPriority.normal,
  }) : id = id ?? const Uuid().v4(),
       userId = userId ?? 'local_user',
       createdAt = createdAt ?? DateTime.now(),
       originalTriggerAt = originalTriggerAt ?? triggerAt,
       isRecurring = isRecurring ?? (recurrenceRule != null),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a new reminder with generated ID (factory kept for compatibility)
  factory Reminder.create({
    required String userId,
    required String title,
    String? body,
    required DateTime triggerAt,
    RecurrenceRule? recurrenceRule,
    String? profileId,
    List<String> tags = const [],
    ReminderPriority priority = ReminderPriority.normal,
  }) {
    final now = DateTime.now();
    return Reminder(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      body: body,
      createdAt: now,
      triggerAt: triggerAt,
      originalTriggerAt: triggerAt,
      recurrenceRule: recurrenceRule,
      isRecurring: recurrenceRule != null,
      updatedAt: now,
      profileId: profileId,
      tags: tags,
      priority: priority,
    );
  }

  /// Create a copy with updated fields
  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? triggerAt,
    DateTime? originalTriggerAt,
    RecurrenceRule? recurrenceRule,
    bool? isRecurring,
    ReminderStatus? status,
    DateTime? snoozedUntil,
    int? lastSnoozeDuration,
    int? version,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    String? profileId,
    List<String>? tags,
    ReminderPriority? priority,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      triggerAt: triggerAt ?? this.triggerAt,
      originalTriggerAt: originalTriggerAt ?? this.originalTriggerAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isRecurring: isRecurring ?? this.isRecurring,
      status: status ?? this.status,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      lastSnoozeDuration: lastSnoozeDuration ?? this.lastSnoozeDuration,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      profileId: profileId ?? this.profileId,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
    );
  }

  /// Snooze the reminder for a given duration
  Reminder snooze(Duration duration) {
    final now = DateTime.now();
    return copyWith(
      status: ReminderStatus.snoozed,
      snoozedUntil: now.add(duration),
      triggerAt: now.add(duration),
      lastSnoozeDuration: duration.inMinutes,
      updatedAt: now,
      version: version + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Complete the reminder (dismiss if non-recurring, advance if recurring)
  Reminder complete() {
    final now = DateTime.now();
    
    if (isRecurring && recurrenceRule != null) {
      // Calculate next occurrence
      final nextTrigger = recurrenceRule!.calculateNextTrigger(originalTriggerAt);
      return copyWith(
        status: ReminderStatus.active,
        triggerAt: nextTrigger,
        originalTriggerAt: nextTrigger,
        snoozedUntil: null,
        updatedAt: now,
        version: version + 1,
        syncStatus: SyncStatus.pending,
      );
    }
    
    return copyWith(
      status: ReminderStatus.completed,
      updatedAt: now,
      version: version + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Skip this occurrence (only for recurring reminders)
  Reminder skip() {
    final now = DateTime.now();
    
    if (isRecurring && recurrenceRule != null) {
      final nextTrigger = recurrenceRule!.calculateNextTrigger(originalTriggerAt);
      return copyWith(
        status: ReminderStatus.active,
        triggerAt: nextTrigger,
        originalTriggerAt: nextTrigger,
        snoozedUntil: null,
        updatedAt: now,
        version: version + 1,
        syncStatus: SyncStatus.pending,
      );
    }
    
    return copyWith(
      status: ReminderStatus.skipped,
      updatedAt: now,
      version: version + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Check if reminder is due
  bool get isDue => triggerAt.isBefore(DateTime.now()) && status == ReminderStatus.active;

  /// Check if reminder is completed
  bool get isCompleted => status == ReminderStatus.completed;

  /// Check if reminder is snoozed
  bool get isSnoozed => status == ReminderStatus.snoozed;

  /// Check if reminder is skipped
  bool get isSkipped => status == ReminderStatus.skipped;

  /// Check if reminder is overdue by more than threshold
  bool isOverdue([Duration threshold = const Duration(minutes: 5)]) {
    return isDue && DateTime.now().difference(triggerAt) > threshold;
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'triggerAt': triggerAt.toIso8601String(),
      'originalTriggerAt': originalTriggerAt.toIso8601String(),
      'recurrenceRule': recurrenceRule?.toJson(),
      'isRecurring': isRecurring,
      'status': status.name,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'lastSnoozeDuration': lastSnoozeDuration,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'profileId': profileId,
      'tags': tags,
      'priority': priority.name,
    };
  }

  /// JSON deserialization
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      triggerAt: DateTime.parse(json['triggerAt'] as String),
      originalTriggerAt: DateTime.parse(json['originalTriggerAt'] as String),
      recurrenceRule: json['recurrenceRule'] != null 
        ? RecurrenceRule.fromJson(json['recurrenceRule'] as Map<String, dynamic>)
        : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      status: ReminderStatus.values.byName(json['status'] as String),
      snoozedUntil: json['snoozedUntil'] != null 
        ? DateTime.parse(json['snoozedUntil'] as String) 
        : null,
      lastSnoozeDuration: json['lastSnoozeDuration'] as int?,
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: SyncStatus.values.byName(json['syncStatus'] as String? ?? 'pending'),
      profileId: json['profileId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      priority: ReminderPriority.values.byName(json['priority'] as String? ?? 'normal'),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Reminder && 
      runtimeType == other.runtimeType && 
      id == other.id &&
      version == other.version;

  @override
  int get hashCode => id.hashCode ^ version.hashCode;
}
