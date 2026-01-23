import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ping/app/theme/ping_theme.dart';

/// Edit reminder screen - placeholder for now
class EditReminderScreen extends ConsumerWidget {
  final String reminderId;

  const EditReminderScreen({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
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
            child: Icon(Icons.arrow_back_ios_rounded, size: 18, color: PingTheme.textSecondary),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Reminder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PingTheme.primaryRed.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 40,
                color: PingTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edit Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PingTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $reminderId',
              style: TextStyle(
                fontSize: 14,
                color: PingTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
