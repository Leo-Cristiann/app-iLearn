import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/screens/educator/create_assignment_screen.dart';
import 'package:project_ilearn/screens/educator/grade_assignments_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/assignment_management_item.dart';
import 'package:provider/provider.dart';

class AssignmentsManagementScreen extends StatefulWidget {
  final String courseId;

  const AssignmentsManagementScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<AssignmentsManagementScreen> createState() => _AssignmentsManagementScreenState();
}

class _AssignmentsManagementScreenState extends State<AssignmentsManagementScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<AssignmentModel> _assignments = [];
  List<AssignmentModel> _pendingAssignments = [];
  List<ModuleModel> _modules = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    await educatorProvider.selectCourse(widget.courseId);

    setState(() {
      _assignments = educatorProvider.assignments;
      _pendingAssignments = educatorProvider.getPendingAssignments();
      _modules = educatorProvider.courseModules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                // All Assignments
                _assignments.isEmpty
                    ? EmptyState(
                        title: 'No assignments yet',
                        message: 'Create your first assignment',
                        icon: Icons.assignment,
                        actionLabel: 'Create Assignment',
                        onActionPressed: () {
                          if (_modules.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You need to create a module first'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateAssignmentScreen(
                                courseId: widget.courseId,
                                modules: _modules,
                              ),
                            ),
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAssignments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            final assignment = _assignments[index];
                            return AssignmentManagementItem(
                              assignment: assignment,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GradeAssignmentsScreen(
                                      assignment: assignment,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                // Pending Assignments
                _pendingAssignments.isEmpty
                    ? const EmptyState(
                        title: 'No pending assignments',
                        message: 'All assignments have been graded',
                        icon: Icons.check_circle,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAssignments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pendingAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment = _pendingAssignments[index];
                            return AssignmentManagementItem(
                              assignment: assignment,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GradeAssignmentsScreen(
                                      assignment: assignment,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: _modules.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateAssignmentScreen(
                      courseId: widget.courseId,
                      modules: _modules,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}