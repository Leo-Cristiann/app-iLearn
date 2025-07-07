import 'package:flutter/material.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/screens/educator/create_assignment_screen.dart';
import 'package:project_ilearn/screens/educator/create_quiz_screen.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:project_ilearn/providers/educator_provider.dart';

class ModuleManagementItem extends StatelessWidget {
  final ModuleModel module;
  final String courseId;

  const ModuleManagementItem({
    super.key,
    required this.module,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${module.contentItems.length} contents · ${module.assignments.length} assignments · ${module.quizzes.length} quizzes',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        leading: const Icon(
          Icons.folder,
          color: AppTheme.primaryColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Horizontal Scrollable Row with buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildActionButton(
                        context,
                        'Add Content',
                        Icons.insert_drive_file,
                        AppTheme.accentColor,
                        () {
                          _showAddContentDialog(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        context,
                        'Add Assignment',
                        Icons.assignment,
                        AppTheme.successColor,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateAssignmentScreen(
                                courseId: courseId,
                                modules: [module],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        context,
                        'Add Quiz',
                        Icons.quiz,
                        AppTheme.warningColor,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateQuizScreen(
                                courseId: courseId,
                                modules: [module],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _showAddContentDialog(BuildContext context) {
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
                          module.id,
                          titleController.text,
                          contentType,
                          contentController.text,
                        );
                        
                        if (success) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Content added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            Navigator.of(dialogContext).pop();
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(educatorProvider.error ?? 'Failed to add content'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
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
}