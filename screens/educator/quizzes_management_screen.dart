import 'package:flutter/material.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/screens/educator/create_quiz_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/quiz_management_item.dart';
import 'package:project_ilearn/screens/educator/quiz_result_screen.dart';
import 'package:provider/provider.dart';

class QuizzesManagementScreen extends StatefulWidget {
  final String courseId;

  const QuizzesManagementScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<QuizzesManagementScreen> createState() => _QuizzesManagementScreenState();
}

class _QuizzesManagementScreenState extends State<QuizzesManagementScreen> {
  bool _isLoading = false;
  List<QuizModel> _quizzes = [];
  List<ModuleModel> _modules = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
    await educatorProvider.selectCourse(widget.courseId);

    setState(() {
      _quizzes = educatorProvider.quizzes;
      _modules = educatorProvider.courseModules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _quizzes.isEmpty
              ? EmptyState(
                  title: 'No quizzes yet',
                  message: 'Create your first quiz',
                  icon: Icons.quiz,
                  actionLabel: 'Create Quiz',
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
                        builder: (context) => CreateQuizScreen(
                          courseId: widget.courseId,
                          modules: _modules,
                        ),
                      ),
                    );
                  },
                )
              : RefreshIndicator(
                  onRefresh: _loadQuizzes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return QuizManagementItem(
                        quiz: quiz,
                        onViewResults: () {
                          // Navigate to quiz results screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuizResultsScreen(quiz: quiz),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: _modules.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateQuizScreen(
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