import 'package:flutter/material.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String courseId;
  final List<ModuleModel> modules;

  const CreateAssignmentScreen({
    super.key,
    required this.courseId,
    required this.modules,
  });

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ModuleModel _selectedModule;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  int _maxPoints = 100;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedModule = widget.modules.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);

    final assignment = await educatorProvider.createAssignment(
      _selectedModule.id,
      _titleController.text,
      _descriptionController.text,
      _dueDate,
      _maxPoints,
    );

    if (assignment != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(educatorProvider.error ?? 'Failed to create assignment'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assignment'),
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
                    // Module Selector
                    DropdownButtonFormField<ModuleModel>(
                      decoration: const InputDecoration(
                        labelText: 'Module',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedModule,
                      items: widget.modules.map((module) {
                        return DropdownMenuItem<ModuleModel>(
                          value: module,
                          child: Text(module.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedModule = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Assignment Title',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Assignment Description',
                      maxLines: 5,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),

                    // Due Date
                    InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(_dueDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Max Points
                    Row(
                      children: [
                        const Text('Maximum Points:'),
                        Expanded(
                          child: Slider(
                            value: _maxPoints.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: _maxPoints.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxPoints = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(_maxPoints.toString()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    CustomButton(
                      onPressed: _createAssignment,
                      text: 'Create Assignment',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}