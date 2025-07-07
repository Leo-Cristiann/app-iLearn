import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/screens/educator/assignments_management_screen.dart';
import 'package:project_ilearn/screens/educator/create_assignment_screen.dart';
import 'package:project_ilearn/screens/educator/create_quiz_screen.dart';
import 'package:project_ilearn/screens/educator/quizzes_management_screen.dart';
import 'package:project_ilearn/screens/educator/students_list_screen.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/course_analytics_card.dart';
import 'package:provider/provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isLoading = true;
  CourseModel? _course;
  final List<int> _expandedModuleIndices = [];

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    await educatorProvider.selectCourse(widget.courseId);

    setState(() {
      _course = educatorProvider.selectedCourse;
      _isLoading = false;
    });
  }

  Future<void> _publishCourse() async {
    if (_course == null) return;

    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    final success = await educatorProvider.publishCourse(_course!.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course published successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(educatorProvider.error ?? 'Failed to publish course'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _course = educatorProvider.selectedCourse;
        _isLoading = false;
      });
    }
  }

  void _showAddModuleDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Module'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Module Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Module Description',
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
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              Navigator.of(context).pop();

              setState(() {
                _isLoading = true;
              });

              final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
              await educatorProvider.addModuleToCourse(
                widget.courseId,
                titleController.text,
                descriptionController.text,
              );

              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                
                // Refresh the data
                _loadCourse();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final educatorProvider = Provider.of<EducatorProvider>(context);
    final modules = educatorProvider.courseModules;

    return Scaffold(
      appBar: AppBar(
        title: Text(_course?.title ?? 'Course Details'),
        actions: [
          if (_course?.status == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: _publishCourse,
              tooltip: 'Publish Course',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'students':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StudentsListScreen(courseId: widget.courseId),
                    ),
                  );
                  break;
                case 'assignments':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AssignmentsManagementScreen(courseId: widget.courseId),
                    ),
                  );
                  break;
                case 'quizzes':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizzesManagementScreen(courseId: widget.courseId),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'students',
                child: Text('View Students'),
              ),
              const PopupMenuItem(
                value: 'assignments',
                child: Text('Manage Assignments'),
              ),
              const PopupMenuItem(
                value: 'quizzes',
                child: Text('Manage Quizzes'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _course == null
              ? const Center(
                  child: Text('Course not found'),
                )
              : RefreshIndicator(
                  onRefresh: _loadCourse,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _course!.status == 'active'
                                ? AppTheme.successColor
                                : _course!.status == 'draft'
                                    ? AppTheme.warningColor
                                    : AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _course!.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Course Info
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _course!.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _course!.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 16,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _course!.subject,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_course!.enrolledStudents.length}/${_course!.maxStudents}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Analytics
                        if (_course!.status == 'active') ...[
                          Text(
                            'Analytics',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          
                          // Menggunakan widget CourseAnalyticsCard dengan parameter course
                          CourseAnalyticsCard(course: _course!),
                          const SizedBox(height: 24),
                        ],

                        // Modules
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Modules',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _showAddModuleDialog,
                              tooltip: 'Add Module',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        modules.isEmpty
                            ? const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No modules created yet. Add a new module to get started.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: modules.length,
                                itemBuilder: (context, index) {
                                  final module = modules[index];
                                  
                                  // Count of items in the module
                                  final contentCount = module.contentItems.length;
                                  final assignmentCount = module.assignments.length;
                                  final quizCount = module.quizzes.length;
                                  
                                  // Check if this module is expanded
                                  final isExpanded = _expandedModuleIndices.contains(index);
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Module header with clickable area
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedModuleIndices.remove(index);
                                              } else {
                                                _expandedModuleIndices.add(index);
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.folder,
                                                  color: AppTheme.primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        module.title,
                                                        style: Theme.of(context).textTheme.titleMedium,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '$contentCount contents · $assignmentCount assignments · $quizCount quizzes',
                                                        style: Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  isExpanded 
                                                    ? Icons.keyboard_arrow_up 
                                                    : Icons.keyboard_arrow_down,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Module actions (only visible when expanded)
                                        if (isExpanded) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: _buildActionButton(
                                                    context,
                                                    'Add Content',
                                                    Icons.article,
                                                    AppTheme.accentColor,
                                                    () => _showAddContentDialog(context, module.id),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _buildActionButton(
                                                    context,
                                                    'Add Assignment',
                                                    Icons.assignment,
                                                    AppTheme.primaryColor,
                                                    () => _navigateToCreateAssignment(context, module),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _buildActionButton(
                                                    context,
                                                    'Add Quiz',
                                                    Icons.quiz,
                                                    AppTheme.secondaryColor,
                                                    () => _navigateToCreateQuiz(context, module),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Show modules content/assignment/quiz summary if there are any
                                          if (contentCount > 0 || assignmentCount > 0 || quizCount > 0) ...[
                                            const Divider(),
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  if (contentCount > 0)
                                                    _buildItemSummary(
                                                      context, 
                                                      'Contents', 
                                                      contentCount, 
                                                      Icons.article, 
                                                      AppTheme.accentColor,
                                                      () => _viewModuleContents(context, module.id)
                                                    ),
                                                  if (assignmentCount > 0)
                                                    _buildItemSummary(
                                                      context, 
                                                      'Assignments', 
                                                      assignmentCount, 
                                                      Icons.assignment, 
                                                      AppTheme.primaryColor,
                                                      () => _navigateToAssignmentsManagement(context)
                                                    ),
                                                  if (quizCount > 0)
                                                    _buildItemSummary(
                                                      context, 
                                                      'Quizzes', 
                                                      quizCount, 
                                                      Icons.quiz, 
                                                      AppTheme.secondaryColor,
                                                      () => _navigateToQuizzesManagement(context)
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: _course?.status == 'draft'
          ? FloatingActionButton.extended(
              onPressed: _publishCourse,
              icon: const Icon(Icons.publish),
              label: const Text('Publish'),
            )
          : null,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildItemSummary(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
    VoidCallback onTap
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(26),
              radius: 20,
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContentDialog(BuildContext context, String moduleId) {
    final titleController = TextEditingController();
    String contentType = 'text';
    final contentController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Content'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Content Title',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: contentType,
                decoration: const InputDecoration(
                  labelText: 'Content Type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'text',
                    child: Text('Text'),
                  ),
                  DropdownMenuItem(
                    value: 'video',
                    child: Text('Video'),
                  ),
                  DropdownMenuItem(
                    value: 'pdf',
                    child: Text('PDF'),
                  ),
                  DropdownMenuItem(
                    value: 'link',
                    child: Text('External Link'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      contentType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter text, video URL, or external link',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (titleController.text.isEmpty || contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Title and content are required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Menampilkan indikator loading
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        // Simpan konten ke Firestore
                        final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
                        final success = await educatorProvider.addContentToModule(
                          moduleId,
                          titleController.text,
                          contentType,
                          contentController.text,
                        );
                        
                        if (success) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Content added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            Navigator.of(dialogContext).pop();
                            
                            // Refresh the data
                            _loadCourse();
                          }
                        } else {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(educatorProvider.error ?? 'Failed to add content'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (dialogContext.mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateAssignment(BuildContext context, ModuleModel module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateAssignmentScreen(
          courseId: widget.courseId,
          modules: [module],
        ),
      ),
    ).then((_) => _loadCourse());
  }

  void _navigateToCreateQuiz(BuildContext context, ModuleModel module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(
          courseId: widget.courseId,
          modules: [module],
        ),
      ),
    ).then((_) => _loadCourse());
  }

  void _viewModuleContents(BuildContext context, String moduleId) {
    // Implementasi untuk melihat konten modul
    // Di sini bisa dibuat screen baru untuk melihat konten secara detail
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Module Contents'),
        content: const Text('This feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToAssignmentsManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssignmentsManagementScreen(courseId: widget.courseId),
      ),
    ).then((_) => _loadCourse());
  }

  void _navigateToQuizzesManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizzesManagementScreen(courseId: widget.courseId),
      ),
    ).then((_) => _loadCourse());
  }
}