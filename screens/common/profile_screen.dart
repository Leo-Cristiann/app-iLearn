import 'package:flutter/material.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/screens/common/edit_profile_screen.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context, user),
            const SizedBox(height: 30),
            _buildProfileInfo(context, user),
            const SizedBox(height: 30),
            _buildActions(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Column(
      children: [
        // Profile Image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Username
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Email
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        // User Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.userType == 'student'
                ? AppTheme.accentColor.withAlpha(26)
                : AppTheme.secondaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.userType == 'student' ? 'Student' : 'Educator',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: user.userType == 'student'
                  ? AppTheme.accentColor
                  : AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, UserModel user) {
    // Profile Information
    final profileData = user.profileData;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Member Since
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Member Since',
              value: '${user.joinedDate.day}/${user.joinedDate.month}/${user.joinedDate.year}',
            ),
            // Specialization (for educators)
            if (user is EducatorModel && user.specialization.isNotEmpty)
              _buildInfoRow(
                icon: Icons.school,
                title: 'Specialization',
                value: user.specialization,
              ),
            // Full Name
            if (profileData.containsKey('fullName'))
              _buildInfoRow(
                icon: Icons.person,
                title: 'Full Name',
                value: profileData['fullName']!,
              ),
            // Phone
            if (profileData.containsKey('phone'))
              _buildInfoRow(
                icon: Icons.phone,
                title: 'Phone',
                value: profileData['phone']!,
              ),
            // Bio
            if (profileData.containsKey('bio'))
              _buildInfoRow(
                icon: Icons.info,
                title: 'Bio',
                value: profileData['bio']!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        // Edit Profile Button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        // Logout Button
        OutlinedButton.icon(
          onPressed: () async {
            // Show confirmation dialog
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}