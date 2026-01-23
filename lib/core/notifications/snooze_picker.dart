import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/core/notifications/notification_service.dart';

/// Custom snooze picker bottom sheet
///
/// Shows quick options (5, 10, 15, 30, 60 min) and custom input
/// Can be triggered from:
/// 1. In-app reminder card long press
/// 2. Notification action (via notification inline reply or overlay)
class CustomSnoozeSheet extends StatefulWidget {
  final String reminderId;
  final String reminderTitle;
  final int lastSnoozeDuration;
  final Function(int minutes) onSnooze;

  const CustomSnoozeSheet({
    super.key,
    required this.reminderId,
    required this.reminderTitle,
    required this.lastSnoozeDuration,
    required this.onSnooze,
  });

  /// Show the snooze picker as a bottom sheet
  static Future<int?> show(
    BuildContext context, {
    required String reminderId,
    required String reminderTitle,
    int? lastSnoozeDuration,
  }) async {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomSnoozeSheet(
        reminderId: reminderId,
        reminderTitle: reminderTitle,
        lastSnoozeDuration: lastSnoozeDuration ??
            NotificationService.instance.lastSnoozeDuration,
        onSnooze: (minutes) => Navigator.of(context).pop(minutes),
      ),
    );
  }

  @override
  State<CustomSnoozeSheet> createState() => _CustomSnoozeSheetState();
}

class _CustomSnoozeSheetState extends State<CustomSnoozeSheet> {
  final _customController = TextEditingController();
  bool _showCustomInput = false;
  int? _selectedDuration;

  final List<int> _quickOptions = [5, 10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.lastSnoozeDuration;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PingTheme.cardWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PingTheme.textSecondary.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PingTheme.primaryRed.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.snooze,
                        color: PingTheme.primaryRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Snooze Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PingTheme.textPrimary,
                          ),
                        ),
                        Text(
                          widget.reminderTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: PingTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick options
              Text(
                'QUICK OPTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: PingTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickOptions.map((minutes) {
                  final isSelected =
                      _selectedDuration == minutes && !_showCustomInput;
                  return GestureDetector(
                    onTap: () => _selectDuration(minutes),
                    child: AnimatedContainer(
                      duration: 150.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? PingTheme.primaryRed : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? PingTheme.primaryRed
                              : PingTheme.textSecondary.withAlpha(100),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        CustomSnoozePicker.formatDuration(minutes),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : PingTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custom input
              GestureDetector(
                onTap: () =>
                    setState(() => _showCustomInput = !_showCustomInput),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _showCustomInput
                        ? PingTheme.primaryRed.withAlpha(20)
                        : PingTheme.bgLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showCustomInput
                          ? PingTheme.primaryRed
                          : PingTheme.textSecondary.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: _showCustomInput
                            ? PingTheme.primaryRed
                            : PingTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Custom duration (e.g., 22 minutes)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _showCustomInput
                              ? PingTheme.primaryRed
                              : PingTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _showCustomInput
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: PingTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Custom input field
              if (_showCustomInput) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: PingTheme.neumorphicCard,
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: PingTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '22',
                      hintStyle: TextStyle(
                          color: PingTheme.textSecondary.withAlpha(100)),
                      suffixText: 'minutes',
                      suffixStyle: TextStyle(
                        fontSize: 16,
                        color: PingTheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      final parsed = CustomSnoozePicker.parseInput(value);
                      if (parsed != null) {
                        setState(() => _selectedDuration = parsed);
                      }
                    },
                    onSubmitted: (_) => _confirmSnooze(),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 150.ms)
                    .slideY(begin: -0.1, end: 0),
              ],

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDuration != null ? _confirmSnooze : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PingTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _selectedDuration != null
                        ? 'Snooze for ${CustomSnoozePicker.formatDuration(_selectedDuration!)}'
                        : 'Select a duration',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }

  void _selectDuration(int minutes) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDuration = minutes;
      _showCustomInput = false;
    });
  }

  void _confirmSnooze() {
    if (_selectedDuration != null) {
      HapticFeedback.mediumImpact();
      widget.onSnooze(_selectedDuration!);
    }
  }
}
