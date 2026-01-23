import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:ping/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:ping/features/reminders/presentation/widgets/empty_state.dart';
import 'package:ping/features/reminders/presentation/widgets/calendar_widget.dart';
import 'package:ping/features/reminders/presentation/widgets/reminders_summary_card.dart';
import 'package:ping/features/reminders/domain/reminder.dart';

/// Main reminders screen - "Upcoming" view from design
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isCalendarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: reminders.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (reminderList) {
            debugPrint(
                'RemindersScreen: Displaying ${reminderList.length} reminders');
            if (reminderList.isEmpty) {
              return _buildEmptyState();
            }
            return _buildContent(reminderList);
          },
        ),
      ),
    );
  }

  Widget _buildContent(List reminderList) {
    // Filter reminders by selected date
    final filteredReminders = reminderList.where((r) {
      final reminderDate = r.triggerAt;
      return reminderDate.year == _selectedDate.year &&
          reminderDate.month == _selectedDate.month &&
          reminderDate.day == _selectedDate.day;
    }).toList();

    // Group reminders by time of day and sort each group
    // Sort: active reminders first (newest to oldest), then completed reminders (newest to oldest)
    List<Reminder> sortReminders(List<Reminder> reminders) {
      final active = reminders.where((r) => !r.isCompleted).toList()
        ..sort((a, b) =>
            b.triggerAt.compareTo(a.triggerAt)); // Descending (newest first)
      final completed = reminders.where((r) => r.isCompleted).toList()
        ..sort((a, b) =>
            b.triggerAt.compareTo(a.triggerAt)); // Descending (newest first)
      return [...active, ...completed];
    }

    final morning = sortReminders(filteredReminders
        .where((r) => r.triggerAt.hour < 12)
        .toList()
        .cast<Reminder>());
    final afternoon = sortReminders(filteredReminders
        .where((r) => r.triggerAt.hour >= 12 && r.triggerAt.hour < 17)
        .toList()
        .cast<Reminder>());
    final evening = sortReminders(filteredReminders
        .where((r) => r.triggerAt.hour >= 17)
        .toList()
        .cast<Reminder>());

    final completedToday = filteredReminders.where((r) => r.isCompleted).length;
    final totalToday = filteredReminders.length;
    final progressPercent =
        totalToday > 0 ? (completedToday / totalToday * 100).round() : 0;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _buildHeader(),
          ),
        ),

        // Summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildSummaryCard(reminderList),
          ),
        ),

        // Calendar widget
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                CalendarWidget(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                  },
                  isExpanded: _isCalendarExpanded,
                ),
                const SizedBox(height: 12),
                _buildCalendarToggle(),
              ],
            ),
          ),
        ),

        // Progress card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildProgressCard(
                progressPercent, totalToday - completedToday),
          ),
        ),

        // Morning section
        if (morning.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Morning'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: morning[index], index: index),
              ),
              childCount: morning.length,
            ),
          ),
        ],

        // Evening section (moved before Afternoon so new evening reminders appear higher)
        if (evening.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Evening'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: evening[index], index: index),
              ),
              childCount: evening.length,
            ),
          ),
        ],

        // Afternoon section
        if (afternoon.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Afternoon'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: afternoon[index], index: index),
              ),
              childCount: afternoon.length,
            ),
          ),
        ],

        // Empty state for selected date with no reminders
        if (filteredReminders.isEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: PingTheme.primaryRed.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_available,
                      size: 40,
                      color: PingTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders for this date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PingTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select another date or create a new reminder',
                    style: TextStyle(
                      fontSize: 14,
                      color: PingTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final hour = now.hour;

    // Time-based greeting
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: PingTheme.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(
                      begin: -0.1, end: 0, delay: 100.ms, duration: 400.ms),
                ],
              ),
            ),
            Row(
              children: [
                _buildNeumorphicButton(
                  Icons.search,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                // Animated profile avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PingTheme.primaryRed,
                        PingTheme.textSecondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PingTheme.primaryRed.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 24),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        duration: 3000.ms,
                        color: Colors.white.withOpacity(0.3)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isCalendarExpanded = !_isCalendarExpanded);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(30),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: PingTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _isCalendarExpanded ? 'Show Week View' : 'Show Month View',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: PingTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildProgressCard(int percent, int remaining) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '$remaining tasks remaining today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Keep going!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
          _buildProgressRing(percent),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildProgressRing(int percent) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 6,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation(PingTheme.textSecondary),
            ),
          ),
          Center(
            child: Text(
              '$percent%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildNeumorphicButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(40),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: PingTheme.textSecondary, size: 22),
      ),
    );
  }

  Widget _buildSummaryCard(List reminderList) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    final todayCount = reminderList.where((r) {
      final date = r.triggerAt;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    final upcomingCount = reminderList.where((r) {
      return r.triggerAt.isAfter(tomorrow) &&
          r.triggerAt.isBefore(nextWeek) &&
          r.status == ReminderStatus.active;
    }).length;

    final totalActive =
        reminderList.where((r) => r.status == ReminderStatus.active).length;

    return RemindersSummaryCard(
      totalReminders: totalActive,
      todayReminders: todayCount,
      upcomingReminders: upcomingCount,
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'No reminders yet',
      subtitle: 'Tap + to create your first reminder',
    );
  }
}
