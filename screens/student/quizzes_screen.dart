import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/screens/student/take_quiz_screen.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/student/quiz_item.dart';
import 'package:provider/provider.dart';

class QuizzesScreen extends StatefulWidget {
  final String courseId;

  const QuizzesScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<QuizModel> _availableQuizzes = [];
  List<QuizModel> _completedQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
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
        _availableQuizzes = studentProvider.getAvailableQuizzes(student.id);
        _completedQuizzes = studentProvider.getCompletedQuizzes(student.id);
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
    final authProvider = Provider.of<AuthProvider>(context);
    final StudentModel? student = authProvider.user as StudentModel?;

    if (student == null) {
      return const Scaffold(
        body: Center(
          child: Text('User data not available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuizzes,
        child: _buildBody(student),
      ),
    );
  }

  Widget _buildBody(StudentModel student) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorMessage(
        message: _errorMessage!,
        onRetry: _loadQuizzes,
      );
    }

    if (_availableQuizzes.isEmpty && _completedQuizzes.isEmpty) {
      return const EmptyState(
        icon: Icons.quiz_outlined,
        title: 'No Quizzes',
        message: 'There are no quizzes for this course yet.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_availableQuizzes.isNotEmpty) ...[
            Text(
              'Available Quizzes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._availableQuizzes.map((quiz) => QuizItem(
                  quiz: quiz,
                  studentId: student.id,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TakeQuizScreen(
                          quiz: quiz,
                          studentId: student.id,
                        ),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 24),
          ],
          if (_completedQuizzes.isNotEmpty) ...[
            Text(
              'Completed Quizzes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._completedQuizzes.map((quiz) => QuizItem(
                  quiz: quiz,
                  studentId: student.id,
                  onTap: () {
                    // View quiz results
                    final attempts = quiz.attempts[student.id] ?? [];

                    if (attempts.isNotEmpty) {
                      // Show quiz result dialog
                      showDialog(
                        context: context,
                        builder: (context) => _buildQuizResultDialog(quiz, attempts.last, student),
                      );
                    }
                  },
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizResultDialog(QuizModel quiz, QuizAttempt attempt, StudentModel student) {
    return AlertDialog(
      title: Text('Quiz Result: ${quiz.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score: ${attempt.score.toStringAsFixed(1)}%'),
          const SizedBox(height: 8),
          Text('Passing Score: ${quiz.passingScore}%'),
          const SizedBox(height: 8),
          Text(
            attempt.score >= quiz.passingScore
                ? 'Congratulations! You passed the quiz.'
                : 'You did not pass the quiz. You can try again.',
            style: TextStyle(
              color: attempt.score >= quiz.passingScore
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (attempt.score >= quiz.passingScore) // Tambahkan tombol Review jika lulus
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TakeQuizScreen(
                    quiz: quiz,
                    studentId: student.id,
                    readOnly: true, // Mode review
                  ),
                ),
              );
            },
            child: const Text('Review'),
          )
        else // Tombol Try Again jika tidak lulus
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TakeQuizScreen(
                    quiz: quiz,
                    studentId: student.id,
                  ),
                ),
              );
            },
            child: const Text('Try Again'),
          ),
      ],
    );
  }
}