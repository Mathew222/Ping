import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';

/// Full month calendar widget with reminder indicators
class CalendarWidget extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isExpanded;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isExpanded = false,
  });

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    HapticFeedback.selectionClick();
    final today = DateTime.now();
    setState(() {
      _displayMonth = DateTime(today.year, today.month, 1);
    });
    widget.onDateSelected(today);
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);

    return reminders.when(
      loading: () => _buildCalendarSkeleton(),
      error: (err, stack) => _buildCalendarSkeleton(),
      data: (reminderList) {
        // Count reminders per date
        final reminderCounts = <String, int>{};
        for (final reminder in reminderList) {
          final dateKey = _dateKey(reminder.triggerAt);
          reminderCounts[dateKey] = (reminderCounts[dateKey] ?? 0) + 1;
        }

        return _buildCalendar(reminderCounts);
      },
    );
  }

  Widget _buildCalendar(Map<String, int> reminderCounts) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildWeekdayLabels(),
          const SizedBox(height: 8),
          if (widget.isExpanded) _buildMonthGrid(reminderCounts),
          if (!widget.isExpanded) _buildWeekRow(reminderCounts),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCalendarSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      height: widget.isExpanded ? 380 : 120,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Month and Year
        Expanded(
          child: Text(
            key: ValueKey('${_displayMonth.year}-${_displayMonth.month}'),
            '${monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // Navigation buttons
        Row(
          children: [
            _buildNavButton(Icons.today, _goToToday),
            const SizedBox(width: 8),
            _buildNavButton(Icons.chevron_left, _previousMonth),
            const SizedBox(width: 8),
            _buildNavButton(Icons.chevron_right, _nextMonth),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(30),
              offset: const Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: PingTheme.textSecondary),
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow(Map<String, int> reminderCounts) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return Expanded(
            child: _buildDayCell(day, reminderCounts[_dateKey(day)] ?? 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(Map<String, int> reminderCounts) {
    final firstDayOfMonth = _displayMonth;
    final lastDayOfMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0);

    // Calculate starting offset (Monday = 1, Sunday = 7)
    final startOffset = firstDayOfMonth.weekday - 1;
    final totalDays = lastDayOfMonth.day;
    final totalCells = ((startOffset + totalDays) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - startOffset + 1;

        if (dayNumber < 1 || dayNumber > totalDays) {
          return const SizedBox(); // Empty cell
        }

        final date =
            DateTime(_displayMonth.year, _displayMonth.month, dayNumber);
        final reminderCount = reminderCounts[_dateKey(date)] ?? 0;

        return _buildDayCell(date, reminderCount);
      },
    );
  }

  Widget _buildDayCell(DateTime date, int reminderCount) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isPast = date.isBefore(DateTime.now()) && !isToday;
    final hasReminders = reminderCount > 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onDateSelected(date);
      },
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isSelected
              ? PingTheme.textSecondary
              : isToday
                  ? PingTheme.primaryRed.withAlpha(30)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: PingTheme.primaryRed, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date number
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isPast
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha(100)
                        : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            // Reminder count badge
            if (hasReminders) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : PingTheme.textSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reminderCount > 9 ? '9+' : '$reminderCount',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? PingTheme.textSecondary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
