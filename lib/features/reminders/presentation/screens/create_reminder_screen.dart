import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/features/reminders/domain/reminder.dart';
import 'package:ping/features/reminders/domain/recurrence_rule.dart';
import 'package:ping/features/reminders/presentation/providers/reminders_provider.dart';

/// Create reminder screen - neumorphic design
class CreateReminderScreen extends ConsumerStatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  ConsumerState<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen> {
  final _titleController = TextEditingController();
  String _selectedFrequency = 'Once';
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _defaultSnoozeDuration = 10; // Default snooze in minutes
  RecurrenceRule? _customRecurrenceRule; // Store custom recurrence rule
  bool _isLoading = false;

  final _frequencies = ['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildNeumorphicButton(
          Icons.arrow_back_ios_rounded,
          onTap: () => context.pop(),
        ),
        title: const Text('Create'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildNeumorphicButton(Icons.more_horiz),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Details section
            _buildSectionLabel('TASK DETAILS'),
            const SizedBox(height: 12),
            _buildTaskInput(),

            const SizedBox(height: 32),

            // Frequency section
            _buildSectionLabel('FREQUENCY'),
            const SizedBox(height: 12),
            _buildFrequencyChips(),

            const SizedBox(height: 32),

            // Time section
            _buildSectionLabel('TIME'),
            const SizedBox(height: 12),
            _buildTimePicker(),

            const SizedBox(height: 32),

            // Default Snooze Duration section
            _buildSectionLabel('DEFAULT SNOOZE'),
            const SizedBox(height: 12),
            _buildSnoozeDurationPicker(),

            const SizedBox(height: 48),

            // Set Reminder button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
    );
  }

  Widget _buildTaskInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _titleController,
        maxLines: 4,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Remind me to water the monstera...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha(150),
              ),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.mic,
              color: PingTheme.primaryRed,
              size: 24,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFrequencyChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _frequencies.map((freq) {
        final isSelected = _selectedFrequency == freq;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedFrequency = freq);
          },
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? PingTheme.primaryRed
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
            ),
            child: Text(
              freq,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 200.ms, delay: 100.ms);
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PingTheme.primaryRed.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: PingTheme.primaryRed,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(_selectedTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _selectedTime.hour < 12 ? 'AM' : 'PM',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: 200.ms);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: PingTheme.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Set Reminder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.check, size: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildSnoozeDurationPicker() {
    return GestureDetector(
      onTap: _showCustomSnoozeDurationDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PingTheme.textSecondary.withAlpha(50),
          ),
          boxShadow: [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(25),
              offset: const Offset(2, 2),
              blurRadius: 8,
            ),
            BoxShadow(
              color: PingTheme.shadowLight,
              offset: const Offset(-2, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PingTheme.primaryRed.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.snooze,
                    color: PingTheme.primaryRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Snooze Duration',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatSnoozeDuration(_defaultSnoozeDuration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.edit,
              color: PingTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomSnoozeDurationDialog() async {
    final controller =
        TextEditingController(text: _defaultSnoozeDuration.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Default Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter duration in minutes:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., 22',
                suffixText: 'minutes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5, 10, 15, 20, 30, 45, 60].map((min) {
                return ActionChip(
                  label: Text('$min min'),
                  onPressed: () {
                    controller.text = min.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 1440) {
                Navigator.pop(context, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please enter a valid duration (1-1440 minutes)')),
                );
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _defaultSnoozeDuration = result);
    }
  }

  Widget _buildNeumorphicButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: PingTheme.shadowDark.withAlpha(40),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: PingTheme.textSecondary, size: 20),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  String _formatSnoozeDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60} hours';
    } else {
      return '${minutes ~/ 60}h ${minutes % 60}m';
    }
  }

  Future<void> _createReminder() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder title')),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final now = DateTime.now();
      final triggerAt = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      RecurrenceRule? rule;
      if (_selectedFrequency == 'Custom' && _customRecurrenceRule != null) {
        // Use the custom recurrence rule
        rule = _customRecurrenceRule;
      } else if (_selectedFrequency != 'Once') {
        // Use simple recurrence rule
        final interval = _selectedFrequency == 'Yearly' ? 12 : 1;
        rule = RecurrenceRule(
          type: _getRecurrenceType(_selectedFrequency),
          interval: interval,
          startDate: triggerAt,
        );
      }

      final actualTriggerTime = triggerAt.isBefore(now)
          ? triggerAt.add(const Duration(days: 1))
          : triggerAt;

      final reminder = Reminder(
        title: _titleController.text,
        triggerAt: actualTriggerTime,
        recurrenceRule: rule,
        priority: ReminderPriority.normal,
        lastSnoozeDuration: _defaultSnoozeDuration,
      );

      debugPrint(
          'CreateReminderScreen: Creating reminder "${reminder.title}" for ${reminder.triggerAt}');

      await ref.read(reminderActionsProvider.notifier).create(reminder);

      debugPrint('CreateReminderScreen: Reminder created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder set for ${_formatTime(TimeOfDay.fromDateTime(actualTriggerTime))}'),
            backgroundColor: PingTheme.primaryRed,
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('CreateReminderScreen: Error creating reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  RecurrenceType _getRecurrenceType(String freq) {
    switch (freq) {
      case 'Daily':
        return RecurrenceType.daily;
      case 'Weekly':
        return RecurrenceType.weekly;
      case 'Monthly':
      case 'Yearly':
        return RecurrenceType.monthly;
      default:
        return RecurrenceType.daily;
    }
  }
}
