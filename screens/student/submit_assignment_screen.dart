import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final bool readOnly;
  
  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
    this.readOnly = false,
  });

  @override
  State<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  File? _selectedFile;
  String? _selectedFileName;
  SubmissionData? _existingSubmission;
  
  @override
  void initState() {
    super.initState();
    _checkExistingSubmission();
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
  
  void _checkExistingSubmission() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user != null && authProvider.user is StudentModel) {
      final student = authProvider.user as StudentModel;
      final submission = widget.assignment.submissions[student.id];
      
      if (submission != null) {
        setState(() {
          _existingSubmission = submission;
          _contentController.text = submission.content;
        });
      }
    }
  }
  
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.first.path!);
        _selectedFileName = result.files.first.name;
      });
    }
  }
  
  Future<void> _submitAssignment() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    if (authProvider.user == null || authProvider.user is! StudentModel) {
      setState(() {
        _errorMessage = 'User not found or not a student';
      });
      return;
    }
    
    final student = authProvider.user as StudentModel;
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    
    try {
      // For simplicity, we're just submitting the text content
      // In a real app, you would upload the file to storage
      String submissionContent = _contentController.text;
      
      if (_selectedFile != null) {
        submissionContent += '\n\nAttached file: $_selectedFileName';
      }
      
      final result = await studentProvider.submitAssignment(
        widget.assignment.id,
        student.id,
        submissionContent,
      );
      
      if (result) {
        // Reload the course details immediately after submission
        if (studentProvider.selectedCourse != null) {
          await studentProvider.loadCourseModules(studentProvider.selectedCourse!.id);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return to previous screen faster
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = studentProvider.error ?? 'Failed to submit assignment';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Metode untuk memformat tanggal
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    final isPastDue = DateTime.now().isAfter(widget.assignment.dueDate);
    final canSubmit = !widget.readOnly && !isPastDue && _existingSubmission?.status != 'graded';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.assignment.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Due: ${formatDate(widget.assignment.dueDate)}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPastDue ? Colors.red : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Points: ${widget.assignment.maxPoints}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_existingSubmission?.status == 'graded') ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grade',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Score: ${_existingSubmission!.grade} / ${widget.assignment.maxPoints}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Feedback:',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _existingSubmission!.feedback ?? 'No feedback provided',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'Your Submission',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (isPastDue && _existingSubmission == null)
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This assignment is past due. You can no longer submit.',
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                CustomTextField(
                  controller: _contentController,
                  hintText: 'Your Answer',
                  maxLines: 10,
                  readOnly: !canSubmit,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your answer';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              if (canSubmit) ...[
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_selectedFileName != null)
                      Expanded(
                        child: Text(
                          _selectedFileName!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                CustomButton(
                  text: _existingSubmission == null ? 'Submit Assignment' : 'Update Submission',
                  isLoading: _isSubmitting,
                  onPressed: _submitAssignment,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}