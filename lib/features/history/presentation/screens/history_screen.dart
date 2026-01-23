import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';

/// History screen - shows completed, snoozed, and skipped reminders
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedTab = 'All';
  final _tabs = ['All', 'Active', 'Archived'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildHeader(),
              ),
            ),

            // Tab bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _buildTabBar(),
              ),
            ),

            // Today section
            SliverToBoxAdapter(
              child: _buildDateSection('TODAY'),
            ),

            // Example reminders (would come from provider)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: _buildSampleCard(index),
                ),
                childCount: 2,
              ),
            ),

            // Yesterday section
            SliverToBoxAdapter(
              child: _buildDateSection('YESTERDAY'),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: _buildSampleCard(index + 2),
                ),
                childCount: 2,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PingTheme.primaryRed.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.history_rounded,
                color: PingTheme.primaryRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        _buildNeumorphicButton(Icons.tune_rounded),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: PingTheme.neumorphicCard,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? PingTheme.primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : PingTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildDateSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: PingTheme.primaryRed.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: PingTheme.primaryRed,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PingTheme.primaryRed,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCard(int index) {
    // Sample data - in real app this comes from provider
    final samples = [
      {'title': 'Drink Water', 'time': '10:30 AM', 'status': 'done'},
      {'title': 'Call Mom', 'time': '8:15 AM', 'status': 'snoozed'},
      {'title': 'Daily Workout', 'time': '6:00 PM', 'status': 'done'},
      {'title': 'Evening Meditation', 'time': '9:00 PM', 'status': 'skipped'},
    ];

    if (index >= samples.length) return const SizedBox.shrink();

    final sample = samples[index];
    final statusColor = sample['status'] == 'done'
        ? PingTheme.statusDone
        : (sample['status'] == 'snoozed'
            ? PingTheme.statusSnoozed
            : PingTheme.statusSkipped);
    final statusLabel = sample['status']!.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PingTheme.neumorphicCard,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PingTheme.primaryRed.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: PingTheme.primaryRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sample['time']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: PingTheme.textSecondary,
                  ),
                ),
                Text(
                  sample['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PingTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
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
}
