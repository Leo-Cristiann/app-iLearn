import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/screens/student/course_detail_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/student/course_item.dart';
import 'package:provider/provider.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<CourseModel> _enrolledCourses = [];
  
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null || authProvider.user is! StudentModel) {
        setState(() {
          _errorMessage = 'User not found or not a student';
          _isLoading = false;
        });
        return;
      }
      
      final student = authProvider.user as StudentModel;
      
      await studentProvider.loadEnrolledCourses(student.id);
      
      setState(() {
        _enrolledCourses = studentProvider.enrolledCourses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCourses,
        child: _buildBody(),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    if (_errorMessage != null) {
      return ErrorMessage(
        message: _errorMessage!,
        onRetry: _loadCourses,
      );
    }
    
    if (_enrolledCourses.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'No Enrolled Courses',
        message: 'You have not enrolled in any courses yet.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _enrolledCourses.length,
      itemBuilder: (context, index) {
        final course = _enrolledCourses[index];
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final student = authProvider.user as StudentModel;
        final enrollment = student.enrolledCourses[course.id];
        final progress = enrollment?.progress ?? 0;
        
        return GestureDetector(
          onTap: () => _navigateToCourseDetail(course),
          child: CourseItem(
            course: course,
            progress: progress,
          ),
        );
      },
    );
  }
}