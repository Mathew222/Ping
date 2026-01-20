import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/domain/reminder.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:ping/core/notifications/snooze_picker.dart';
import 'package:ping/core/notifications/notification_service.dart';
import 'package:intl/intl.dart';

/// Neumorphic reminder card with status badge and checkbox
class ReminderCard extends ConsumerWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      onLongPress: () => _showSnoozeSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: PingTheme.neumorphicCard,
        child: Row(
          children: [
            // Icon circle
            _buildIconCircle(),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PingTheme.textPrimary,
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(reminder.triggerAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: PingTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge or checkbox
            _buildTrailing(context, ref),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }

  void _showSnoozeSheet(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();

    final minutes = await CustomSnoozeSheet.show(
      context,
      reminderId: reminder.id,
      reminderTitle: reminder.title,
    );

    if (minutes != null) {
      ref.read(reminderActionsProvider.notifier).snooze(
            reminder.id,
            Duration(minutes: minutes),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Snoozed for ${CustomSnoozePicker.formatDuration(minutes)}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Implement undo snooze
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildIconCircle() {
    final IconData icon;
    final Color color;

    // Choose icon based on reminder category/priority
    switch (reminder.priority) {
      case ReminderPriority.high:
        icon = Icons.priority_high_rounded;
        color = PingTheme.primaryOrange;
        break;
      case ReminderPriority.low:
        icon = Icons.bookmark_outline_rounded;
        color = PingTheme.dustyRose;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = PingTheme.primaryMint;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildTrailing(BuildContext context, WidgetRef ref) {
    // Show status badge for completed/snoozed/skipped
    if (reminder.isCompleted) {
      return _StatusBadge(
        label: 'DONE',
        color: PingTheme.statusDone,
      );
    }

    if (reminder.snoozedUntil != null) {
      return _StatusBadge(
        label: 'SNOOZED',
        color: PingTheme.statusSnoozed,
      );
    }

    // Show checkbox for pending items
    return GestureDetector(
      onTap: () => _toggleComplete(ref),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PingTheme.dustyRose.withAlpha(40),
          border: Border.all(
            color: PingTheme.dustyRose.withAlpha(100),
            width: 2,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  void _toggleComplete(WidgetRef ref) async {
    HapticFeedback.mediumImpact();

    // If recurring, show dialog with options
    if (reminder.isRecurring) {
      final result = await showDialog<String>(
        context: ref.context,
        builder: (context) => AlertDialog(
          title: Text(
            'Recurring Reminder',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: PingTheme.textPrimary,
            ),
          ),
          content: Text(
            'This is a recurring reminder. What would you like to do?',
            style: TextStyle(color: PingTheme.textSecondary),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text(
                'Cancel',
                style: TextStyle(color: PingTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'complete'),
              child: Text(
                'Complete This Occurrence',
                style: TextStyle(color: PingTheme.primaryMint),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'stop'),
              child: Text(
                'Stop Recurring',
                style: TextStyle(
                  color: PingTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (result == 'complete') {
        ref.read(reminderActionsProvider.notifier).complete(reminder.id);
      } else if (result == 'stop') {
        ref.read(reminderActionsProvider.notifier).stopRecurring(reminder.id);
      }
    } else {
      // Non-recurring, just complete it
      ref.read(reminderActionsProvider.notifier).complete(reminder.id);
    }
  }

  void _showDetails(BuildContext context) {
    // TODO: Navigate to details or show bottom sheet
  }
}

/// Status badge widget (DONE, SNOOZED, SKIPPED)
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Expanded reminder card for History view (with image and description)
class ExpandedReminderCard extends StatelessWidget {
  final Reminder reminder;
  final String? imageUrl;

  const ExpandedReminderCard({
    super.key,
    required this.reminder,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = reminder.isCompleted
        ? PingTheme.statusDone
        : (reminder.snoozedUntil != null
            ? PingTheme.statusSnoozed
            : PingTheme.statusSkipped);
    final statusLabel = reminder.isCompleted
        ? 'DONE'
        : (reminder.snoozedUntil != null ? 'SNOOZED' : 'SKIPPED');

    return Container(
      decoration: PingTheme.neumorphicCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PingTheme.primaryMint.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: PingTheme.primaryMint,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(reminder.triggerAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: PingTheme.textSecondary,
                        ),
                      ),
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PingTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),
          ),

          // Description
          if (reminder.body != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '"${reminder.body}"',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: PingTheme.textSecondary,
                ),
              ),
            ),

          // Image
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // View Details button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 16, color: PingTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PingTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
