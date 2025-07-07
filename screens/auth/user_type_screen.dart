import 'package:flutter/material.dart';
import 'package:project_ilearn/screens/auth/register_screen.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  // Fungsi untuk pilih tipe user dan navigasi ke halaman register
  void _selectUserType(BuildContext context, String userType) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => RegisterScreen(userType: userType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 450;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Type'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width > 600 ? size.width * 0.1 : 24, 
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'I want to use iLearn as',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 24 : 40),
                
                // User Type Cards - Stack vertically on small screens
                isSmallScreen
                    ? Column(
                        children: [
                          _userTypeCard(
                            context: context,
                            title: 'Student',
                            description: 'Join courses, access learning materials, submit assignments, and track your progress.',
                            icon: Icons.school_outlined,
                            onPressed: () => _selectUserType(context, 'student'),
                          ),
                          const SizedBox(height: 24),
                          _userTypeCard(
                            context: context,
                            title: 'Educator',
                            description: 'Create courses, manage learning materials, grade assignments, and track student progress.',
                            icon: Icons.menu_book_outlined,
                            onPressed: () => _selectUserType(context, 'educator'),
                          ),
                        ],
                      )
                    // On larger screens, display side by side if there's enough space
                    : size.width > 900
                        ? Row(
                            children: [
                              Expanded(
                                child: _userTypeCard(
                                  context: context,
                                  title: 'Student',
                                  description: 'Join courses, access learning materials, submit assignments, and track your progress.',
                                  icon: Icons.school_outlined,
                                  onPressed: () => _selectUserType(context, 'student'),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _userTypeCard(
                                  context: context,
                                  title: 'Educator',
                                  description: 'Create courses, manage learning materials, grade assignments, and track student progress.',
                                  icon: Icons.menu_book_outlined,
                                  onPressed: () => _selectUserType(context, 'educator'),
                                ),
                              ),
                            ],
                          )
                        // Default to column for medium screens
                        : Column(
                            children: [
                              _userTypeCard(
                                context: context,
                                title: 'Student',
                                description: 'Join courses, access learning materials, submit assignments, and track your progress.',
                                icon: Icons.school_outlined,
                                onPressed: () => _selectUserType(context, 'student'),
                              ),
                              const SizedBox(height: 24),
                              _userTypeCard(
                                context: context,
                                title: 'Educator',
                                description: 'Create courses, manage learning materials, grade assignments, and track student progress.',
                                icon: Icons.menu_book_outlined,
                                onPressed: () => _selectUserType(context, 'educator'),
                              ),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTypeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF828282),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue as $title',
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}