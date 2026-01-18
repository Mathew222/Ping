import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping/features/reminders/domain/recurrence_rule.dart';

/// Recurrence rule editor bottom sheet
class RecurrenceEditor extends StatefulWidget {
  final RecurrenceRule? initialRule;
  final DateTime triggerDate;

  const RecurrenceEditor({
    super.key,
    this.initialRule,
    required this.triggerDate,
  });

  @override
  State<RecurrenceEditor> createState() => _RecurrenceEditorState();
}

class _RecurrenceEditorState extends State<RecurrenceEditor> {
  RecurrenceType? _selectedType;
  int _interval = 1;
  final Set<int> _selectedDays = {};
  int? _dayOfMonth;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialRule != null) {
      _selectedType = widget.initialRule!.type;
      _interval = widget.initialRule!.interval;
      if (widget.initialRule!.daysOfWeek != null) {
        _selectedDays.addAll(widget.initialRule!.daysOfWeek!);
      }
      _dayOfMonth = widget.initialRule!.dayOfMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Never'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quick options
            _buildQuickOptions(),
            
            if (_selectedType != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Interval selector
              _buildIntervalSelector(),
              
              // Day selector for weekly
              if (_selectedType == RecurrenceType.weekly) ...[
                const SizedBox(height: 16),
                _buildDaySelector(),
              ],
              
              // Preview
              const SizedBox(height: 16),
              _buildPreview(),
            ],
            
            const SizedBox(height: 24),
            
            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedType == null ? null : _confirm,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickChip(
          label: 'Daily',
          selected: _selectedType == RecurrenceType.daily,
          onTap: () => setState(() {
            _selectedType = RecurrenceType.daily;
            _interval = 1;
          }),
        ),
        _QuickChip(
          label: 'Weekdays',
          selected: _selectedType == RecurrenceType.weekly && 
            _selectedDays.containsAll([1, 2, 3, 4, 5]) && 
            !_selectedDays.contains(0) && 
            !_selectedDays.contains(6),
          onTap: () => setState(() {
            _selectedType = RecurrenceType.weekly;
            _selectedDays.clear();
            _selectedDays.addAll([1, 2, 3, 4, 5]);
            _interval = 1;
          }),
        ),
        _QuickChip(
          label: 'Weekly',
          selected: _selectedType == RecurrenceType.weekly && _selectedDays.isEmpty,
          onTap: () => setState(() {
            _selectedType = RecurrenceType.weekly;
            _selectedDays.clear();
            _interval = 1;
          }),
        ),
        _QuickChip(
          label: 'Monthly',
          selected: _selectedType == RecurrenceType.monthly,
          onTap: () => setState(() {
            _selectedType = RecurrenceType.monthly;
            _dayOfMonth = widget.triggerDate.day;
            _interval = 1;
          }),
        ),
        _QuickChip(
          label: 'Custom',
          selected: _selectedType == RecurrenceType.custom,
          onTap: () => setState(() {
            _selectedType = RecurrenceType.custom;
          }),
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    final unitText = switch (_selectedType) {
      RecurrenceType.hourly => _interval == 1 ? 'hour' : 'hours',
      RecurrenceType.daily => _interval == 1 ? 'day' : 'days',
      RecurrenceType.weekly => _interval == 1 ? 'week' : 'weeks',
      RecurrenceType.monthly => _interval == 1 ? 'month' : 'months',
      RecurrenceType.custom => 'minutes',
      null => '',
    };

    return Row(
      children: [
        const Text('Every'),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
            ),
            controller: TextEditingController(text: _interval.toString()),
            onChanged: (value) {
              final n = int.tryParse(value);
              if (n != null && n > 0) {
                setState(() => _interval = n);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(unitText),
      ],
    );
  }

  Widget _buildDaySelector() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'On these days',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final selected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (selected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: selected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final rule = _buildRule();
    if (rule == null) return const SizedBox.shrink();
    
    final previews = rule.previewOccurrences(3, widget.triggerDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next occurrences',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        ...previews.map((date) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
    return '$weekday, $month ${date.day} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  RecurrenceRule? _buildRule() {
    if (_selectedType == null) return null;
    
    final sortedDays = _selectedDays.isNotEmpty 
        ? (_selectedDays.toList()..sort()) 
        : null;
    
    return RecurrenceRule(
      type: _selectedType!,
      interval: _interval,
      daysOfWeek: sortedDays,
      dayOfMonth: _dayOfMonth,
      customMinutes: _selectedType == RecurrenceType.custom ? _interval : null,
      startDate: widget.triggerDate,
    );
  }

  void _confirm() {
    final rule = _buildRule();
    Navigator.pop(context, rule);
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
