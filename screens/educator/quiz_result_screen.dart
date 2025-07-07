import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:project_ilearn/widgets/educator/quiz_result_item.dart';
import 'package:provider/provider.dart';

class QuizResultsScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  bool _isLoading = true;
  List<StudentModel> _students = [];
  
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);
      _students = educatorProvider.enrolledStudents;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Result: ${widget.quiz.title}'),
      ),
      body: _isLoading 
        ? const LoadingIndicator()
        : _buildResults(),
    );
  }
  
  Widget _buildResults() {
    // Cek apakah ada hasil quiz
    if (widget.quiz.attempts.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_late,
        title: 'No results yet',
        message: 'No students have taken this quiz yet',
      );
    }
    
    // Buat list dari student IDs yang sudah mengerjakan quiz
    final List<String> studentIds = widget.quiz.attempts.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: studentIds.length,
      itemBuilder: (context, index) {
        final studentId = studentIds[index];
        final attempts = widget.quiz.attempts[studentId] ?? [];
        
        // Cari data student berdasarkan ID
        final student = _students.firstWhere(
          (s) => s.id == studentId,
          orElse: () => StudentModel(
            id: studentId,
            username: 'Unknown Student',
            email: '',
            joinedDate: DateTime.now(),
          ),
        );
        
        // Gunakan quiz_result_item yang sudah ada
        return QuizResultItem(
          quiz: widget.quiz,
          studentId: studentId,
          attempts: attempts,
          student: student,
          onTap: () {
            // Tampilkan detail jawaban (opsional)
            _showQuizAnswerDetails(context, student, attempts.last);
          },
        );
      },
    );
  }
  
  void _showQuizAnswerDetails(
    BuildContext context, 
    StudentModel student, 
    QuizAttempt attempt
  ) {
    // Implementasi untuk menampilkan detail jawaban (opsional)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Answer ${student.username}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              Text('Score: ${attempt.score.toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              const Text('Answer:'),
              const SizedBox(height: 8),
              ...attempt.answers.entries.map((entry) {
                // Cari pertanyaan yang cocok
                final question = widget.quiz.questions.firstWhere(
                  (q) => q.id == entry.key,
                  orElse: () => QuestionModel(
                    id: entry.key,
                    text: 'Question not found',
                    correctAnswer: '',
                  ),
                );
                
                final isCorrect = entry.value == question.correctAnswer;
                
                return ListTile(
                  title: Text(question.text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student Answer: ${entry.value}'),
                      Text('Correct Answer:: ${question.correctAnswer}'),
                    ],
                  ),
                  trailing: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}