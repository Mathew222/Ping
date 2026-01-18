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
  ConsumerState<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen> {
  final _titleController = TextEditingController();
  String _selectedFrequency = 'Once';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedLocation;
  bool _isLoading = false;

  final _frequencies = ['Once', 'Daily', 'Weekly', 'Custom'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PingTheme.bgLight,
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
            
            // Time & Location section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('TIME'),
                      const SizedBox(height: 12),
                      _buildTimePicker(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('LOCATION'),
                      const SizedBox(height: 12),
                      _buildLocationPicker(),
                    ],
                  ),
                ),
              ],
            ),
            
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
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: PingTheme.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTaskInput() {
    return Container(
      decoration: PingTheme.neumorphicCard,
      child: TextField(
        controller: _titleController,
        maxLines: 4,
        style: TextStyle(
          fontSize: 16,
          color: PingTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Remind me to water the monstera...',
          hintStyle: TextStyle(
            color: PingTheme.textSecondary.withAlpha(150),
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.mic,
              color: PingTheme.primaryOrange,
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
            decoration: PingTheme.neumorphicPill(
              selected: isSelected,
              color: PingTheme.primaryOrange,
            ),
            child: Text(
              freq,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : PingTheme.textPrimary,
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
        decoration: PingTheme.neumorphicCard,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PingTheme.primaryOrange.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: PingTheme.primaryOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(_selectedTime),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PingTheme.textPrimary,
                  ),
                ),
                Text(
                  _selectedTime.hour < 12 ? 'AM' : 'PM',
                  style: TextStyle(
                    fontSize: 12,
                    color: PingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: 200.ms);
  }

  Widget _buildLocationPicker() {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: PingTheme.neumorphicCard,
        child: Row(
          children: [
            Icon(
              Icons.navigation_outlined,
              color: PingTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedLocation ?? 'Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PingTheme.textPrimary,
              ),
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
          backgroundColor: PingTheme.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Set Reminder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.check, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNeumorphicButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: PingTheme.cardWhite,
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

  void _pickLocation() {
    // TODO: Implement location picker
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
        now.year, now.month, now.day,
        _selectedTime.hour, _selectedTime.minute,
      );
      
      RecurrenceRule? rule;
      if (_selectedFrequency != 'Once') {
        rule = RecurrenceRule(
          type: _getRecurrenceType(_selectedFrequency),
          interval: 1,
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
      );

      debugPrint('CreateReminderScreen: Creating reminder "${reminder.title}" for ${reminder.triggerAt}');
      
      await ref.read(reminderActionsProvider.notifier).create(reminder);
      
      debugPrint('CreateReminderScreen: Reminder created successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${_formatTime(TimeOfDay.fromDateTime(actualTriggerTime))}'),
            backgroundColor: PingTheme.primaryMint,
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
      case 'Daily': return RecurrenceType.daily;
      case 'Weekly': return RecurrenceType.weekly;
      case 'Custom': return RecurrenceType.custom;
      default: return RecurrenceType.daily;
    }
  }
}
