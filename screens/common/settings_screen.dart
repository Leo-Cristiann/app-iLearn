import 'package:flutter/material.dart';
import 'package:project_ilearn/providers/theme_provider.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildThemeToggle(context, themeProvider),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          const SizedBox(height: 8),
          _buildSettingSwitch(
            context,
            'Push Notifications',
            Icons.notifications,
            true,
            (value) {
              // Handle push notifications setting
            },
          ),
          _buildSettingSwitch(
            context,
            'Email Notifications',
            Icons.email,
            false,
            (value) {
              // Handle email notifications setting
            },
          ),
          
          const SizedBox(height: 24),
          
          // Privacy Section
          _buildSectionHeader(context, 'Privacy'),
          const SizedBox(height: 8),
          _buildSettingTile(
            context,
            'Privacy Policy',
            Icons.privacy_tip,
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          _buildSettingTile(
            context,
            'Terms of Service',
            Icons.description,
            onTap: () {
              // Navigate to terms of service
            },
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildSettingTile(
            context,
            'App Version',
            Icons.info,
            trailing: const Text('1.0.0'),
          ),
          _buildSettingTile(
            context,
            'Contact Support',
            Icons.support_agent,
            onTap: () {
              // Open contact support
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.brightness_6),
            const SizedBox(width: 16),
            const Text(
              'Dark Theme',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setDarkMode(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    BuildContext context,
    String title,
    IconData icon,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Switch(
              value: initialValue,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}