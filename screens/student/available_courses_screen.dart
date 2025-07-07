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

class AvailableCoursesScreen extends StatefulWidget {
  const AvailableCoursesScreen({super.key});

  @override
  State<AvailableCoursesScreen> createState() => _AvailableCoursesScreenState();
}

class _AvailableCoursesScreenState extends State<AvailableCoursesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<CourseModel> _availableCourses = [];
  List<String> _enrolledCourseIds = [];
  
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
      _enrolledCourseIds = student.enrolledCourses.keys.toList();
      
      await studentProvider.loadAvailableCourses();
      
      setState(() {
        _availableCourses = studentProvider.availableCourses
            .where((course) => !_enrolledCourseIds.contains(course.id))
            .toList();
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
        title: const Text('Available Courses'),
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
    
    if (_availableCourses.isEmpty) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'No Available Courses',
        message: 'There are no available courses at the moment.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableCourses.length,
      itemBuilder: (context, index) {
        final course = _availableCourses[index];
        
        return GestureDetector(
          onTap: () => _navigateToCourseDetail(course),
          child: CourseItem(course: course),
        );
      },
    );
  }
}