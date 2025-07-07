import 'package:flutter/material.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  int _maxStudents = 50;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  // Simple required validator function to replace the missing Validators class
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);

    if (authProvider.user != null) {
      final success = await educatorProvider.createCourse(
        _titleController.text,
        _descriptionController.text,
        _subjectController.text,
        _maxStudents,
        authProvider.user!.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(educatorProvider.error ?? 'Failed to create course'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Course Title',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Course Description',
                      maxLines: 5,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _subjectController,
                      labelText: 'Subject',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Maximum Students:'),
                        Expanded(
                          child: Slider(
                            value: _maxStudents.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: _maxStudents.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxStudents = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(_maxStudents.toString()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _createCourse,
                      text: 'Create Course',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}