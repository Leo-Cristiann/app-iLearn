import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/assignment_submission_item.dart';
import 'package:provider/provider.dart';

class GradeAssignmentsScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const GradeAssignmentsScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<GradeAssignmentsScreen> createState() => _GradeAssignmentsScreenState();
}

class _GradeAssignmentsScreenState extends State<GradeAssignmentsScreen> {
  bool _isLoading = false;
  bool _isGrading = false;
  List<StudentModel> _students = [];
  Map<String, SubmissionData> _submissions = {};

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    _students = educatorProvider.enrolledStudents;
    _submissions = widget.assignment.submissions;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _gradeSubmission(String studentId, double grade, String feedback) async {
    setState(() {
      _isGrading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    final success = await educatorProvider.gradeAssignment(
      widget.assignment.id,
      studentId,
      grade,
      feedback,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission graded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await educatorProvider.loadCourseModules(educatorProvider.selectedCourse?.id ?? '');

      // Update local submissions
      final updatedAssignment = educatorProvider.assignments.firstWhere(
        (a) => a.id == widget.assignment.id,
        orElse: () => widget.assignment,
      );

      setState(() {
        _submissions = updatedAssignment.submissions;
        _isGrading = false;
      });

      if (!mounted) return;
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(educatorProvider.error ?? 'Failed to grade submission'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isGrading = false;
      });
    }
  }

  void _showGradeDialog(String studentId, SubmissionData submission) {
    final gradeController = TextEditingController(
      text: submission.grade?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grade Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: 'Grade (0-100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (gradeController.text.isEmpty) return;

              final grade = double.tryParse(gradeController.text) ?? 0;
              if (grade < 0 || grade > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grade must be between 0 and 100'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();
              _gradeSubmission(
                studentId,
                grade,
                feedbackController.text,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get student list from submissions
    final submittedStudents = _submissions.keys.toList();
    
    // Get students who haven't submitted
    final notSubmittedStudents = _students
        .where((student) => !submittedStudents.contains(student.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment.title),
      ),
      body: _isLoading || _isGrading
          ? const LoadingIndicator()
          : _submissions.isEmpty
              ? const EmptyState(
                  title: 'No submissions yet',
                  message: 'Wait for students to submit their assignments',
                  icon: Icons.assignment_turned_in,
                )
              : RefreshIndicator(
                  onRefresh: _loadSubmissions,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Assignment Info
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assignment Details',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.assignment.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Due Date: ${widget.assignment.dueDate.toString().substring(0, 16)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Maximum Points: ${widget.assignment.maxPoints}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submissions
                        Text(
                          'Submissions (${_submissions.length}/${_students.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        
                        // Submitted assignments
                        ...submittedStudents.map((studentId) {
                          final student = _students.firstWhere(
                            (s) => s.id == studentId,
                            orElse: () => StudentModel(
                              id: studentId,
                              username: 'Unknown Student',
                              email: '',
                              joinedDate: DateTime.now(),
                            ),
                          );
                          final submission = _submissions[studentId]!;
                          
                          return AssignmentSubmissionItem(
                            assignment: widget.assignment,
                            studentId: studentId,
                            submission: submission,
                            student: student,
                            onTap: () => _showGradeDialog(studentId, submission),
                          );
                        }),
                        
                        // Not submitted
                        if (notSubmittedStudents.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Not Submitted',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...notSubmittedStudents.map((student) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  student.username.substring(0, 1).toUpperCase(),
                                ),
                              ),
                              title: Text(student.username),
                              subtitle: Text(student.email),
                              trailing: const Text(
                                'Not submitted',
                                style: TextStyle(color: AppTheme.errorColor),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}