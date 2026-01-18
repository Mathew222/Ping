/// Recurrence rule types
enum RecurrenceType {
  hourly,
  daily,
  weekly,
  monthly,
  custom,
}

/// Recurrence Rule Engine
/// 
/// Implements the mathematical model:
/// next_trigger = f(rule, last_trigger, user_action)
/// 
/// Key principle: Snoozing creates a temporary override, 
/// the original recurrence pattern remains intact.
class RecurrenceRule {
  final RecurrenceType type;
  final int interval; // Every N units
  
  // Weekly specifics
  final List<int>? daysOfWeek; // 0-6, Sunday = 0
  
  // Monthly specifics
  final int? dayOfMonth; // 1-31
  final int? weekOfMonth; // 1-5
  
  // Custom interval
  final int? customMinutes; // For arbitrary intervals
  
  // Bounds
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;
  
  // Special handling
  final bool skipWeekends;
  final bool skipHolidays;

  const RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.weekOfMonth,
    this.customMinutes,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
    this.skipWeekends = false,
    this.skipHolidays = false,
  });

  /// Calculate the next trigger time based on the last trigger
  /// 
  /// Formula: next_trigger = f(rule, last_trigger)
  DateTime calculateNextTrigger(DateTime lastTrigger) {
    DateTime next;
    
    switch (type) {
      case RecurrenceType.hourly:
        next = lastTrigger.add(Duration(hours: interval));
        break;
        
      case RecurrenceType.daily:
        next = lastTrigger.add(Duration(days: interval));
        break;
        
      case RecurrenceType.weekly:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          // Find the next matching day
          next = _findNextWeekday(lastTrigger, daysOfWeek!);
        } else {
          next = lastTrigger.add(Duration(days: 7 * interval));
        }
        break;
        
      case RecurrenceType.monthly:
        if (dayOfMonth != null) {
          next = _addMonths(lastTrigger, interval, dayOfMonth!);
        } else if (weekOfMonth != null && daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          // e.g., "First Monday of every month"
          next = _findNthWeekdayOfMonth(lastTrigger, weekOfMonth!, daysOfWeek!.first, interval);
        } else {
          next = _addMonths(lastTrigger, interval, lastTrigger.day);
        }
        break;
        
      case RecurrenceType.custom:
        final minutes = customMinutes ?? 60;
        next = lastTrigger.add(Duration(minutes: minutes));
        break;
    }
    
    // Handle skip weekends
    if (skipWeekends) {
      while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
        next = next.add(const Duration(days: 1));
      }
    }
    
    // Check bounds
    if (endDate != null && next.isAfter(endDate!)) {
      return lastTrigger; // No more occurrences
    }
    
    return next;
  }

  /// Find the next occurrence on one of the specified weekdays
  DateTime _findNextWeekday(DateTime from, List<int> weekdays) {
    // Sort weekdays for easier searching
    final sorted = List<int>.from(weekdays)..sort();
    
    // Find next day
    DateTime next = from.add(const Duration(days: 1));
    
    while (true) {
      // Convert to 0-based weekday (Sunday = 0)
      final weekday = next.weekday % 7;
      if (sorted.contains(weekday)) {
        // If this is the first week, just return
        if (next.difference(from).inDays <= 7) {
          return next;
        }
        // Otherwise apply interval
        final weeksToAdd = (interval - 1) * 7;
        return next.add(Duration(days: weeksToAdd));
      }
      next = next.add(const Duration(days: 1));
    }
  }

  /// Add months while preserving day of month
  DateTime _addMonths(DateTime from, int months, int targetDay) {
    var year = from.year;
    var month = from.month + months;
    
    while (month > 12) {
      month -= 12;
      year++;
    }
    
    // Clamp day to last day of month if needed
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay;
    
    return DateTime(year, month, day, from.hour, from.minute);
  }

  /// Find the Nth weekday of a month (e.g., "2nd Tuesday")
  DateTime _findNthWeekdayOfMonth(DateTime from, int n, int weekday, int monthsToAdd) {
    var year = from.year;
    var month = from.month + monthsToAdd;
    
    while (month > 12) {
      month -= 12;
      year++;
    }
    
    // Find first of month
    var firstOfMonth = DateTime(year, month, 1, from.hour, from.minute);
    
    // Find first occurrence of weekday
    var daysUntilWeekday = (weekday - firstOfMonth.weekday % 7 + 7) % 7;
    var firstOccurrence = firstOfMonth.add(Duration(days: daysUntilWeekday));
    
    // Add weeks to get to Nth occurrence
    return firstOccurrence.add(Duration(days: (n - 1) * 7));
  }

  /// Generate the next N occurrences (for preview)
  List<DateTime> previewOccurrences(int count, [DateTime? startFrom]) {
    final occurrences = <DateTime>[];
    var current = startFrom ?? startDate;
    
    for (var i = 0; i < count; i++) {
      current = calculateNextTrigger(current);
      
      // Check if we've hit the end
      if (endDate != null && current.isAfter(endDate!)) break;
      if (maxOccurrences != null && i >= maxOccurrences!) break;
      
      occurrences.add(current);
    }
    
    return occurrences;
  }

  /// Human-readable description
  String get description {
    switch (type) {
      case RecurrenceType.hourly:
        return interval == 1 ? 'Every hour' : 'Every $interval hours';
        
      case RecurrenceType.daily:
        return interval == 1 ? 'Every day' : 'Every $interval days';
        
      case RecurrenceType.weekly:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          final days = daysOfWeek!.map(_weekdayName).join(', ');
          return interval == 1 ? 'Every $days' : 'Every $interval weeks on $days';
        }
        return interval == 1 ? 'Every week' : 'Every $interval weeks';
        
      case RecurrenceType.monthly:
        if (dayOfMonth != null) {
          return interval == 1 
            ? 'Monthly on day $dayOfMonth' 
            : 'Every $interval months on day $dayOfMonth';
        }
        if (weekOfMonth != null && daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          final ordinal = _ordinal(weekOfMonth!);
          final day = _weekdayName(daysOfWeek!.first);
          return interval == 1 
            ? 'Monthly on the $ordinal $day'
            : 'Every $interval months on the $ordinal $day';
        }
        return interval == 1 ? 'Monthly' : 'Every $interval months';
        
      case RecurrenceType.custom:
        final mins = customMinutes ?? 60;
        if (mins >= 60 && mins % 60 == 0) {
          final hours = mins ~/ 60;
          return 'Every $hours hour${hours > 1 ? 's' : ''}';
        }
        return 'Every $mins minutes';
    }
  }

  String _weekdayName(int weekday) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[weekday % 7];
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'weekOfMonth': weekOfMonth,
      'customMinutes': customMinutes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxOccurrences': maxOccurrences,
      'skipWeekends': skipWeekends,
      'skipHolidays': skipHolidays,
    };
  }

  /// JSON deserialization
  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: RecurrenceType.values.byName(json['type'] as String),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.cast<int>(),
      dayOfMonth: json['dayOfMonth'] as int?,
      weekOfMonth: json['weekOfMonth'] as int?,
      customMinutes: json['customMinutes'] as int?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
        ? DateTime.parse(json['endDate'] as String) 
        : null,
      maxOccurrences: json['maxOccurrences'] as int?,
      skipWeekends: json['skipWeekends'] as bool? ?? false,
      skipHolidays: json['skipHolidays'] as bool? ?? false,
    );
  }

  /// Common preset constructors
  factory RecurrenceRule.daily({int interval = 1, required DateTime startDate}) {
    return RecurrenceRule(type: RecurrenceType.daily, interval: interval, startDate: startDate);
  }

  factory RecurrenceRule.weekly({
    int interval = 1,
    List<int>? daysOfWeek,
    required DateTime startDate,
  }) {
    return RecurrenceRule(
      type: RecurrenceType.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
      startDate: startDate,
    );
  }

  factory RecurrenceRule.monthly({
    int interval = 1,
    int? dayOfMonth,
    required DateTime startDate,
  }) {
    return RecurrenceRule(
      type: RecurrenceType.monthly,
      interval: interval,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
    );
  }

  factory RecurrenceRule.everyNMinutes(int minutes, {required DateTime startDate}) {
    return RecurrenceRule(
      type: RecurrenceType.custom,
      customMinutes: minutes,
      startDate: startDate,
    );
  }
}
