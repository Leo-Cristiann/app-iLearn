import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/student/schedule_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleScreen extends StatefulWidget {
  final String courseId;
  
  const ScheduleScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  CourseModel? _course;
  
  @override
  void initState() {
    super.initState();
    _loadCourse();
  }
  
  Future<void> _loadCourse() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      
      await studentProvider.selectCourse(widget.courseId);
      
      if (studentProvider.error != null) {
        setState(() {
          _errorMessage = studentProvider.error;
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _course = studentProvider.selectedCourse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _joinMeeting() async {
    if (_course?.courseClass == null) {
      return;
    }
    
    final courseClass = _course!.courseClass!;
    
    if (courseClass.type == 'Synchronous' && courseClass.meetingUrl.isNotEmpty) {
      final url = Uri.parse(courseClass.meetingUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch the meeting URL'),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No meeting URL available'),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    if (_errorMessage != null) {
      return ErrorMessage(
        message: _errorMessage!,
        onRetry: _loadCourse,
      );
    }
    
    if (_course == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Course Not Found',
        message: 'The course you are looking for does not exist.',
      );
    }
    
    if (_course!.courseClass == null) {
      return const EmptyState(
        icon: Icons.schedule_outlined,
        title: 'No Schedule',
        message: 'This course does not have a scheduled class.',
      );
    }
    
    final courseClass = _course!.courseClass!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Schedule',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course: ${_course!.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${courseClass.type}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Day: ${courseClass.day}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${courseClass.time}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  if (courseClass.type == 'Asynchronous' && courseClass.classroom.isNotEmpty)
                    Text(
                      'Location: ${courseClass.classroom}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else if (courseClass.type == 'Synchronous' && courseClass.meetingUrl.isNotEmpty) ...[
                    Text(
                      'Meeting URL: ${courseClass.meetingUrl}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _joinMeeting,
                      icon: const Icon(Icons.video_call),
                      label: const Text('Join Meeting'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Upcoming Classes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ScheduleItem(
            course: _course!,
            date: DateTime.now().add(const Duration(days: 7)),
          ),
        ],
      ),
    );
  }
}