import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:ping/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:ping/features/reminders/presentation/widgets/empty_state.dart';

/// Main reminders screen - "Upcoming" view from design
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  DateTime _selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    
    return Scaffold(
      backgroundColor: PingTheme.bgLight,
      body: SafeArea(
        child: reminders.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (reminderList) {
            debugPrint('RemindersScreen: Displaying ${reminderList.length} reminders');
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
    // Group reminders by time of day
    final now = DateTime.now();
    final morning = reminderList.where((r) => r.triggerAt.hour < 12).toList();
    final afternoon = reminderList.where((r) => r.triggerAt.hour >= 12 && r.triggerAt.hour < 17).toList();
    final evening = reminderList.where((r) => r.triggerAt.hour >= 17).toList();
    
    final completedToday = reminderList.where((r) => r.isCompleted).length;
    final totalToday = reminderList.length;
    final progressPercent = totalToday > 0 ? (completedToday / totalToday * 100).round() : 0;
    
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _buildHeader(),
          ),
        ),
        
        // Date picker row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildDatePicker(),
          ),
        ),
        
        // Progress card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildProgressCard(progressPercent, totalToday - completedToday),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: morning[index]),
              ),
              childCount: morning.length,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: afternoon[index]),
              ),
              childCount: afternoon.length,
            ),
          ),
        ],
        
        // Evening section
        if (evening.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Evening'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: ReminderCard(reminder: evening[index]),
              ),
              childCount: evening.length,
            ),
          ),
        ],
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              '${weekday[now.weekday - 1]}, ${month[now.month - 1]} ${now.day}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            _buildNeumorphicButton(
              Icons.search,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [PingTheme.dustyRose.withAlpha(150), PingTheme.paleRose],
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.day == _selectedDate.day;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDate = day);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? PingTheme.dustyRose : PingTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? null : [
                  BoxShadow(
                    color: PingTheme.shadowDark.withAlpha(40),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNames[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : PingTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : PingTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(int percent, int remaining) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PingTheme.neumorphicCard,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PingTheme.paleRose,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Keep going!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: PingTheme.dustyRose,
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
              backgroundColor: PingTheme.bgLight,
              valueColor: AlwaysStoppedAnimation(PingTheme.dustyRose),
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
          color: PingTheme.cardWhite,
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

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'No reminders yet',
      subtitle: 'Tap + to create your first reminder',
    );
  }
}
