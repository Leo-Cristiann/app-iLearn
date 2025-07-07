import 'package:flutter/material.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/student_item.dart';
import 'package:provider/provider.dart';

class StudentsListScreen extends StatefulWidget {
  final String courseId;

  const StudentsListScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  bool _isLoading = false;
  List<StudentModel> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    await educatorProvider.loadEnrolledStudents(widget.courseId);

    setState(() {
      _students = educatorProvider.enrolledStudents;
      _isLoading = false;
    });
  }

  void _viewStudentDetails(StudentModel student) {
    // Implementasi untuk melihat detail siswa
    // Misalnya, menampilkan dialog atau navigasi ke halaman detail
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.username),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${student.email}'),
            const SizedBox(height: 8),
            Text('Joined: ${student.joinedDate.toString().substring(0, 10)}'),
            const SizedBox(height: 8),
            Text('Status: ${student.isActive ? "Active" : "Inactive"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _students.isEmpty
              ? const EmptyState(
                  title: 'No students yet',
                  message: 'Wait for students to enroll',
                  icon: Icons.people,
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return StudentItem(
                        student: student,
                        onTap: () => _viewStudentDetails(student),
                      );
                    },
                  ),
                ),
    );
  }
}