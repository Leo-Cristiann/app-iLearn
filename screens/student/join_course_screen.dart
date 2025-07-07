import 'package:flutter/material.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/screens/student/course_detail_screen.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class JoinCourseScreen extends StatefulWidget {
  const JoinCourseScreen({super.key});

  @override
  State<JoinCourseScreen> createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _courseIdController.dispose();
    super.dispose();
  }

  Future<void> _findCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseId = _courseIdController.text.trim();
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      
      // Hanya cek apakah kursus ada, tidak mendaftarkan pengguna
      await studentProvider.selectCourse(courseId);
      
      if (studentProvider.error != null) {
        setState(() {
          _errorMessage = studentProvider.error;
          _isLoading = false;
        });
        return;
      }
      
      if (studentProvider.selectedCourse == null) {
        setState(() {
          _errorMessage = 'Course not found';
          _isLoading = false;
        });
        return;
      }
      
      if (studentProvider.selectedCourse!.status != 'active') {
        setState(() {
          _errorMessage = 'This course is not yet active';
          _isLoading = false;
        });
        return;
      }
      
      // Jika kursus ditemukan, arahkan ke halaman detail kursus
      if (mounted) {
        Navigator.pop(context); // Tutup halaman join course
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: courseId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join New Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Course Id',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _courseIdController,
                labelText: 'Course Id',
                hintText: 'Enter the course Id provided by the educator.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course Id';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: LoadingIndicator())
              else
                CustomButton(
                  text: 'Find Course',  // Ubah teks dari 'Join' menjadi 'Find Course'
                  onPressed: _findCourse,  // Ubah fungsi dari _joinCourse menjadi _findCourse
                  width: double.infinity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}