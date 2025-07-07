import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/student/assignment_item.dart';
import 'package:provider/provider.dart';

class AssignmentsScreen extends StatefulWidget {
  final String courseId;
  
  const AssignmentsScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AssignmentModel> _pendingAssignments = [];
  List<AssignmentModel> _completedAssignments = [];
  
  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }
  
  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await studentProvider.selectCourse(widget.courseId);
      
      if (studentProvider.error != null) {
        setState(() {
          _errorMessage = studentProvider.error;
          _isLoading = false;
        });
        return;
      }
      
      if (authProvider.user == null || authProvider.user is! StudentModel) {
        setState(() {
          _errorMessage = 'User not found or not a student';
          _isLoading = false;
        });
        return;
      }
      
      final student = authProvider.user as StudentModel;
      
      setState(() {
        _pendingAssignments = studentProvider.getPendingAssignments(student.id);
        _completedAssignments = studentProvider.getCompletedAssignments(student.id);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignments,
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
        onRetry: _loadAssignments,
      );
    }
    
    if (_pendingAssignments.isEmpty && _completedAssignments.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'No Assignments',
        message: 'There are no assignments for this course yet.',
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pendingAssignments.isNotEmpty) ...[
            Text(
              'Pending Assignments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._pendingAssignments.map((assignment) => AssignmentItem(
              assignment: assignment,
              studentId: (Provider.of<AuthProvider>(context).user as StudentModel).id,
            )),
            const SizedBox(height: 24),
          ],
          if (_completedAssignments.isNotEmpty) ...[
            Text(
              'Completed Assignments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._completedAssignments.map((assignment) => AssignmentItem(
              assignment: assignment,
              studentId: (Provider.of<AuthProvider>(context).user as StudentModel).id,
              isSubmitted: true,
              isGraded: true,
            )),
          ],
        ],
      ),
    );
  }
}