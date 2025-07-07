import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class TakeQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  final String studentId;
  final bool readOnly;

  const TakeQuizScreen({
    super.key,
    required this.quiz,
    required this.studentId,
    this.readOnly = false,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final Map<String, String> _answers = {};
  bool _isSubmitting = false;
  String? _errorMessage;
  int _currentQuestionIndex = 0;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();

    // Jika mode readOnly, isi jawaban dari attempt terakhir
    if (widget.readOnly) {
      _loadPreviousAnswers();
      _confirmed = true; // Langsung ke tampilan quiz
    }
  }

  void _loadPreviousAnswers() {
    final attempts = widget.quiz.attempts[widget.studentId] ?? [];
    if (attempts.isNotEmpty) {
      final lastAttempt = attempts.last;
      setState(() {
        _answers.addAll(lastAttempt.answers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan PopScope dengan onPopInvokedWithResult
    return PopScope(
      canPop: !_confirmed || widget.readOnly, // Izinkan pop hanya jika belum konfirmasi atau mode readOnly
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // Logika tambahan jika diperlukan saat pop dipicu
        if (didPop) return; // Jika pop sudah terjadi, tidak perlu tindakan tambahan
        // Jika pop dicegah (_confirmed == true dan bukan readOnly), tampilkan peringatan
        if (_confirmed && !widget.readOnly) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Quiz?'),
              content: const Text('If you exit, your answers will not be saved.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Tutup dialog
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Keluar dari quiz
                  },
                  child: const Text('Quit'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          automaticallyImplyLeading: !_confirmed || widget.readOnly, // Sembunyikan tombol back saat quiz berlangsung
        ),
        body: _confirmed ? _buildQuizContent() : _buildConfirmationContent(),
      ),
    );
  }

  Widget _buildConfirmationContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            widget.quiz.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Important Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• Time limit: ${widget.quiz.timeLimit} minutes'),
                  Text('• Number of questions: ${widget.quiz.questions.length}'),
                  Text('• Passing score: ${widget.quiz.passingScore}%'),
                  const Text('• You can only take this quiz once at a time'),
                  const Text('• Make sure you have a stable internet connection'),
                ],
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: CustomButton(
              text: 'Start Quiz',
              onPressed: () {
                setState(() {
                  _confirmed = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final questions = widget.quiz.questions;

    if (questions.isEmpty) {
      return const Center(
        child: Text('No questions available for this quiz.'),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final correctAnswer = currentQuestion.correctAnswer;
    final userAnswer = _answers[currentQuestion.id];
    final isCorrect = userAnswer == correctAnswer;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Points: ${currentQuestion.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentQuestion.text,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          if (currentQuestion.questionType == 'multiple_choice')
            _buildMultipleChoiceQuestion(currentQuestion)
          else if (currentQuestion.questionType == 'true_false')
            _buildTrueFalseQuestion(currentQuestion)
          else
            _buildShortAnswerQuestion(currentQuestion),

          // Feedback dalam mode readOnly
          if (widget.readOnly && userAnswer != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCorrect ? 'Correct Answer!' : 'Wrong Answer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!isCorrect && currentQuestion.correctAnswer.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answer: ${currentQuestion.correctAnswer}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (currentQuestion.explanation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Explanation: ${currentQuestion.explanation}',
                    ),
                  ],
                ],
              ),
            ),
          ],

          const Spacer(),
          if (_errorMessage != null) ...[
            Card(
              color: Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                  },
                  child: const Text('Previous'),
                )
              else
                const SizedBox(),
              if (_currentQuestionIndex < questions.length - 1)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex++;
                    });
                  },
                  child: const Text('Next'),
                )
              else if (!widget.readOnly) // Tombol submit hanya muncul jika bukan readOnly
                CustomButton(
                  text: 'Submit Quiz',
                  isLoading: _isSubmitting,
                  onPressed: _submitQuiz,
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                  },
                  child: const Text('Completed Review'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuestion(QuestionModel question) {
    final correctAnswer = question.correctAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.options.map((option) {
        final isCorrectOption = option == correctAnswer;
        final isSelectedOption = _answers[question.id] == option;

        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _answers[question.id],
          onChanged: widget.readOnly ? null : (value) {
            setState(() {
              _answers[question.id] = value!;
            });
          },
          // Visual feedback dalam mode readOnly
          tileColor: widget.readOnly && isSelectedOption
              ? (isCorrectOption ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26))
              : null,
          secondary: widget.readOnly && (isCorrectOption || isSelectedOption)
              ? Icon(
                  isCorrectOption ? Icons.check_circle : Icons.cancel,
                  color: isCorrectOption ? Colors.green : Colors.red,
                )
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseQuestion(QuestionModel question) {
    final correctAnswer = question.correctAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ['True', 'False'].map((option) {
        final isCorrectOption = option == correctAnswer;
        final isSelectedOption = _answers[question.id] == option;

        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _answers[question.id],
          onChanged: widget.readOnly ? null : (value) {
            setState(() {
              _answers[question.id] = value!;
            });
          },
          // Visual feedback dalam mode readOnly
          tileColor: widget.readOnly && isSelectedOption
              ? (isCorrectOption ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26))
              : null,
          secondary: widget.readOnly && (isCorrectOption || isSelectedOption)
              ? Icon(
                  isCorrectOption ? Icons.check_circle : Icons.cancel,
                  color: isCorrectOption ? Colors.green : Colors.red,
                )
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildShortAnswerQuestion(QuestionModel question) {
    final userAnswer = _answers[question.id] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Enter your answer here',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: userAnswer),
          onChanged: widget.readOnly ? null : (value) {
            _answers[question.id] = value;
          },
          readOnly: widget.readOnly,
        ),
        if (widget.readOnly) ...[
          const SizedBox(height: 16),
          Text(
            'Correct answer: ${question.correctAnswer}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  Future<void> _submitQuiz() async {
    // Validate if all questions are answered
    if (_answers.length < widget.quiz.questions.length) {
      setState(() {
        _errorMessage = 'Please answer all questions before submitting';
      });
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      log('Attempting to submit quiz: ${widget.quiz.id} for student: ${widget.studentId}');
      final attempt = await studentProvider.attemptQuiz(
        widget.quiz.id,
        widget.studentId,
        _answers,
      );

      // Log whether attempt was successful
      log('Quiz attempt result: ${attempt != null ? 'success' : 'failed'}');

      if (attempt != null) {
        // Delay course reload to allow for Firestore updates to be processed
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          if (studentProvider.selectedCourse != null) {
            await studentProvider.loadCourseModules(studentProvider.selectedCourse!.id);
          }
        } catch (refreshError) {
          // Don't let a refresh error block quiz completion
          log('Error refreshing course modules: $refreshError');
        }

        if (!mounted) return;

        // Pop and show dialog with results
        Navigator.of(context).pop();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Quiz Results'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score: ${attempt.score.toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  Text('Passing Score: ${widget.quiz.passingScore}%'),
                  const SizedBox(height: 16),
                  Text(
                    attempt.score >= widget.quiz.passingScore
                        ? 'Congratulations! You passed the quiz.'
                        : 'You did not pass the quiz. You can try again.',
                    style: TextStyle(
                      color: attempt.score >= widget.quiz.passingScore
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                if (attempt.score >= widget.quiz.passingScore)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TakeQuizScreen(
                            quiz: widget.quiz,
                            studentId: widget.studentId,
                            readOnly: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Review Answers'),
                  ),
              ],
            ),
          );
        });
      } else {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = studentProvider.error ?? 'Failed to submit quiz';
            log('Error message set: $_errorMessage');
          });
        }
      }
    } catch (e) {
      log('Error in _submitQuiz: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Exception: $e';
        });
      }
    }
  }
}