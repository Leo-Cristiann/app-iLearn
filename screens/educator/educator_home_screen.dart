import 'package:flutter/material.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/screens/auth/login_screen.dart';
import 'package:project_ilearn/screens/common/notifications_screen.dart';
import 'package:project_ilearn/screens/common/profile_screen.dart';
import 'package:project_ilearn/screens/educator/course_detail_screen.dart';
import 'package:project_ilearn/screens/educator/create_course_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/course_management_item.dart';
import 'package:project_ilearn/screens/common/settings_screen.dart';
import 'package:provider/provider.dart';

class EducatorHomeScreen extends StatefulWidget {
  const EducatorHomeScreen({super.key});

  @override
  State<EducatorHomeScreen> createState() => _EducatorHomeScreenState();
}

class _EducatorHomeScreenState extends State<EducatorHomeScreen> {
  int _currentIndex = 0;
  bool _isLoggingOut = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.user != null) {
      await educatorProvider.loadEducatorCourses(authProvider.user!.id);
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
  
  void _navigateToCourseDetail(String courseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: courseId),
      ),
    );
  }
  
  void _navigateToCreateCourse() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateCourseScreen(),
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
  
  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
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
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final educatorProvider = Provider.of<EducatorProvider>(context);
    
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    final educator = authProvider.user as EducatorModel?;
    
    if (educator == null) {
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
              title: const Text('iLearn - Educator'),
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
            body: _buildBody(educator, educatorProvider),
            floatingActionButton: _currentIndex == 0
                ? FloatingActionButton(
                    onPressed: () {}, // Disable during logout
                    child: const Icon(Icons.add),
                  )
                : null,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (_) {}, // Disable during logout
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  label: 'Assignments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  label: 'Students',
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
        title: const Text('iLearn - Educator'),
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
      body: _buildBody(educator, educatorProvider),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToCreateCourse,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody(EducatorModel educator, EducatorProvider educatorProvider) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab(educator, educatorProvider);
      case 1:
        return _buildAssignmentsTab(educator, educatorProvider);
      case 2:
        return _buildStudentsTab(educator, educatorProvider);
      case 3:
        return _buildProfileTab(educator);
      default:
        return _buildDashboardTab(educator, educatorProvider);
    }
  }
  
  Widget _buildDashboardTab(EducatorModel educator, EducatorProvider educatorProvider) {
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
              'Hi, ${educator.username}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to your educator dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF828282),
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Cards
            _buildStatsCards(educator, educatorProvider),
            const SizedBox(height: 24),
            
            // My Courses
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
                  onPressed: _navigateToCreateCourse,
                  child: const Text('Create New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCourses(educatorProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCards(EducatorModel educator, EducatorProvider educatorProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.book_outlined,
            title: 'Courses',
            value: educatorProvider.courses.length.toString(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_outline,
            title: 'Students',
            value: _getTotalStudents(educatorProvider).toString(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment_outlined,
            title: 'Pending',
            value: educatorProvider.getPendingAssignments().length.toString(),
          ),
        ),
      ],
    );
  }
  
  int _getTotalStudents(EducatorProvider educatorProvider) {
    int total = 0;
    
    for (var course in educatorProvider.courses) {
      total += course.enrolledStudents.length;
    }
    
    return total;
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2F80ED),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF828282),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCourses(EducatorProvider educatorProvider) {
    if (educatorProvider.isLoading) {
      return const LoadingIndicator();
    }
    
    if (educatorProvider.error != null) {
      return ErrorMessage(
        message: educatorProvider.error!,
        onRetry: _refreshData,
      );
    }
    
    if (educatorProvider.courses.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'No Courses Yet',
        message: 'You haven\'t created any courses yet. Click on "Create New" to get started.',
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: educatorProvider.courses.length,
      itemBuilder: (context, index) {
        final course = educatorProvider.courses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CourseManagementItem(
            course: course,
            onTap: () => _navigateToCourseDetail(course.id),
          ),
        );
      },
    );
  }
  
  Widget _buildAssignmentsTab(EducatorModel educator, EducatorProvider educatorProvider) {
    // Implementation for Assignments Tab
    return const Center(
      child: Text('Assignments Tab'),
    );
  }
  
  Widget _buildStudentsTab(EducatorModel educator, EducatorProvider educatorProvider) {
    // Implementation for Students Tab
    return const Center(
      child: Text('Students Tab'),
    );
  }
  
  Widget _buildProfileTab(EducatorModel educator) {
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
              educator.username.isNotEmpty
                  ? educator.username[0].toUpperCase()
                  : 'E',
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
            educator.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            educator.email,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF828282),
            ),
          ),
          const SizedBox(height: 8),
          
          // Specialization
          Text(
            educator.specialization,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F80ED),
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