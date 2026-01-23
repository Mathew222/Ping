import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ping/app/theme/ping_theme.dart';
import 'package:ping/app/theme/theme_provider.dart';
import 'package:ping/features/auth/presentation/providers/auth_provider.dart';

/// Settings screen with neumorphic design
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _defaultSnooze = 10;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    final themeString = themeModeNotifier.themeModeString;

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

            // Account Section
            SliverToBoxAdapter(
              child: _buildSection(
                'Account',
                [
                  _buildSettingsTile(
                    icon: user != null ? Icons.person : Icons.person_outline,
                    title: user != null ? 'Profile' : 'Sign In',
                    subtitle: user != null
                        ? user.email
                        : 'Sync reminders across devices',
                    onTap: () => user != null
                        ? context.push('/profile')
                        : context.push('/login'),
                  ),
                ],
              ),
            ),

            // Notifications Section
            SliverToBoxAdapter(
              child: _buildSection(
                'Notifications',
                [
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Sound',
                    value: _soundEnabled,
                    onChanged: (val) => setState(() => _soundEnabled = val),
                  ),
                  _buildSwitchTile(
                    icon: Icons.vibration_outlined,
                    title: 'Vibration',
                    value: _vibrationEnabled,
                    onChanged: (val) => setState(() => _vibrationEnabled = val),
                  ),
                  _buildSettingsTile(
                    icon: Icons.snooze_outlined,
                    title: 'Default Snooze',
                    subtitle: '$_defaultSnooze minutes',
                    onTap: () => _showSnoozePicker(),
                  ),
                ],
              ),
            ),

            // Appearance Section
            SliverToBoxAdapter(
              child: _buildSection(
                'Appearance',
                [
                  _buildSettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    subtitle: themeString,
                    onTap: () => _showThemePicker(),
                  ),
                ],
              ),
            ),

            // Data Section
            SliverToBoxAdapter(
              child: _buildSection(
                'Data',
                [
                  _buildSettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Export Reminders',
                    onTap: () => _exportReminders(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.upload_outlined,
                    title: 'Import Reminders',
                    onTap: () => _importReminders(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Clear All Data',
                    titleColor: Colors.red,
                    onTap: () => _showClearDataDialog(),
                  ),
                ],
              ),
            ),

            // About Section
            SliverToBoxAdapter(
              child: _buildSection(
                'About',
                [
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _openPrivacyPolicy(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.code,
                    title: 'Open Source Licenses',
                    onTap: () => _showLicenses(),
                  ),
                ],
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
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: PingTheme.primaryRed.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.settings_outlined,
            color: PingTheme.primaryRed,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PingTheme.primaryRed,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PingTheme.primaryRed.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: PingTheme.primaryRed, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right,
                    color: PingTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PingTheme.primaryRed.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: PingTheme.primaryRed, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
            activeColor: PingTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: const Text(
            'Sign in with your account to sync reminders across all your devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign in coming soon!')),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSnoozePicker() {
    final durations = [5, 10, 15, 20, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default Snooze Duration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...durations.map((d) => ListTile(
                  title: Text('$d minutes'),
                  trailing: _defaultSnooze == d
                      ? Icon(Icons.check, color: PingTheme.primaryRed)
                      : null,
                  onTap: () {
                    setState(() => _defaultSnooze = d);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showThemePicker() {
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    final currentThemeString = themeModeNotifier.themeModeString;

    final themes = [
      {
        'name': 'System',
        'mode': ThemeMode.system,
        'icon': Icons.brightness_auto
      },
      {'name': 'Light', 'mode': ThemeMode.light, 'icon': Icons.light_mode},
      {'name': 'Dark', 'mode': ThemeMode.dark, 'icon': Icons.dark_mode},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...themes.map((t) => ListTile(
                  leading: Icon(t['icon'] as IconData),
                  title: Text(t['name'] as String),
                  trailing: currentThemeString == t['name']
                      ? Icon(Icons.check, color: PingTheme.primaryRed)
                      : null,
                  onTap: () {
                    themeModeNotifier.setThemeMode(t['mode'] as ThemeMode);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _exportReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  void _importReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon!')),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all your reminders. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy...')),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Ping',
      applicationVersion: '1.0.0',
    );
  }
}
