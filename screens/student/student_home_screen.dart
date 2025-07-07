import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/screens/auth/login_screen.dart';
import 'package:project_ilearn/screens/common/notifications_screen.dart';
import 'package:project_ilearn/screens/common/profile_screen.dart';
import 'package:project_ilearn/screens/student/course_detail_screen.dart';
import 'package:project_ilearn/screens/student/join_course_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/student/course_item.dart';
import 'package:project_ilearn/screens/common/settings_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  bool _isLoggingOut = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.user != null) {
      final student = authProvider.user as StudentModel;
      studentProvider.currentStudentId = student.id;
      await studentProvider.loadEnrolledCourses(student.id);
    }
  }
  
  Future<void> _refreshData() async {
    await _loadData();
  }
  
  Future<void> _logout() async {
    // Tangkap BuildContext dan provider sebelum operasi async apa pun
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    // Proceed with logout only if user confirmed
    if (confirm == true) {
      // Tampilkan loading indicator
      setState(() {
        _isLoggingOut = true;
      });
      
      try {
        // Simulasi delay untuk loading (opsional, dapat dihapus jika tidak diperlukan)
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Lakukan operasi logout
        await authProvider.logout();
        
        // Periksa apakah widget masih terpasang sebelum melanjutkan
        if (!mounted) return;
        
        // Gunakan navigator yang sudah disimpan
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (routeContext) => const LoginScreen(),
          ),
        );
      } finally {
        // Pastikan loading indicator dimatikan jika terjadi error
        // atau jika navigasi tidak terjadi
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
        }
      }
    }
  }
  
  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  
  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }
  
  Future<void> _navigateToJoinCourse() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JoinCourseScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh data jika berhasil bergabung ke kursus
      _refreshData();
    }
  }
  
  void _navigateToCourseDetail(CourseModel course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: course.id),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    final student = authProvider.user as StudentModel?;
    
    if (student == null) {
      return const Scaffold(
        body: Center(
          child: Text('User data not available'),
        ),
      );
    }
    
    // Tampilkan overlay loading jika sedang proses logout
    if (_isLoggingOut) {
      return Stack(
        children: [
          // Tetap tampilkan UI normal di background
          Scaffold(
            appBar: AppBar(
              title: const Text('iLearn'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {}, // Disable during logout
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {}, // Disable during logout
                ),
              ],
            ),
            body: _buildBody(student, studentProvider),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (_) {}, // Disable during logout
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  label: 'Assignments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_outlined),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          // Loading overlay
          Container(
            color: Colors.black.withAlpha(77),
            child: const LoadingIndicator(
              message: 'Logging out...',
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('iLearn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _buildBody(student, studentProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody(StudentModel student, StudentProvider studentProvider) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(student, studentProvider);
      case 1:
        return _buildAssignmentsTab(student, studentProvider);
      case 2:
        return _buildScheduleTab(student, studentProvider);
      case 3:
        return _buildProfileTab(student);
      default:
        return _buildHomeTab(student, studentProvider);
    }
  }
  
  Widget _buildHomeTab(StudentModel student, StudentProvider studentProvider) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hi, ${student.username}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to learn today?',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF828282),
              ),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF828282),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search for courses...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) {
                        // Implementasi pencarian
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Join New Course Button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton.icon(
                onPressed: _navigateToJoinCourse,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Join New Course',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Enrolled Courses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to My Courses Screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEnrolledCourses(student, studentProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnrolledCourses(StudentModel student, StudentProvider studentProvider) {
    if (studentProvider.isLoading) {
      return const LoadingIndicator();
    }
    
    if (studentProvider.error != null) {
      return ErrorMessage(
        message: studentProvider.error!,
        onRetry: _refreshData,
      );
    }
    
    log("Building UI for ${studentProvider.enrolledCourses.length} enrolled courses");
    
    if (studentProvider.enrolledCourses.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'No Courses Yet',
        message: 'You haven\'t enrolled in any courses yet. Join available courses to get started.',
      );
    }
    
    // Use ListView instead of horizontal list to ensure visibility
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: studentProvider.enrolledCourses.length,
      itemBuilder: (context, index) {
        final course = studentProvider.enrolledCourses[index];
        final progress = studentProvider.getStudentProgress(course.id);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _navigateToCourseDetail(course),
            child: CourseItem(
              course: course,
              progress: progress,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAssignmentsTab(StudentModel student, StudentProvider studentProvider) {
    // Implementasi untuk Tab Assignments
    return const Center(
      child: Text('Assignments Tab'),
    );
  }
  
  Widget _buildScheduleTab(StudentModel student, StudentProvider studentProvider) {
    // Implementasi untuk Tab Schedule
    return const Center(
      child: Text('Schedule Tab'),
    );
  }
  
  Widget _buildProfileTab(StudentModel student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF2F80ED).withAlpha(26),
            child: Text(
              student.username.isNotEmpty
                  ? student.username[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F80ED),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Username
          Text(
            student.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            student.email,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF828282),
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Options
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: _navigateToProfile,
          ),
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: _navigateToNotifications,
          ),
          _buildProfileOption(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: _navigateToSettings,
          ),
          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Navigate to Help & Support
            },
          ),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Logout',
            onTap: _logout,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? const Color(0xFF333333),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? const Color(0xFF333333),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF828282),
            ),
          ],
        ),
      ),
    );
  }
}