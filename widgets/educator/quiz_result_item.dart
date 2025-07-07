import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:intl/intl.dart';

class QuizResultItem extends StatelessWidget {
  final QuizModel quiz;
  final String studentId;
  final List<QuizAttempt> attempts;
  final StudentModel? student;
  final VoidCallback onTap;

  const QuizResultItem({
    super.key,
    required this.quiz,
    required this.studentId,
    required this.attempts,
    this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final latestAttempt = attempts.isNotEmpty ? attempts.last : null;
    final isPassed = latestAttempt != null && latestAttempt.score >= quiz.passingScore;
    final attemptsCount = attempts.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(context, isPassed ? 'passed' : 'failed'),
                ],
              ),
              const SizedBox(height: 8),
              if (student != null)
                Text(
                  'Student: ${student!.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              const SizedBox(height: 4),
              if (latestAttempt != null)
                Text(
                  'Latest attempt: ${DateFormat('MMM dd, yyyy, HH:mm').format(latestAttempt.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildResultItem(
                    context,
                    Icons.scoreboard,
                    latestAttempt != null
                        ? '${latestAttempt.score.toStringAsFixed(1)}%'
                        : 'N/A',
                    'Score',
                    isPassed ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 16),
                  _buildResultItem(
                    context,
                    Icons.replay,
                    '$attemptsCount',
                    'Attempts',
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildResultItem(
                    context,
                    Icons.access_time,
                    '${quiz.timeLimit} min',
                    'Time Limit',
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (latestAttempt != null) ...[
                LinearProgressIndicator(
                  value: latestAttempt.score / 100,
                  backgroundColor: Colors.grey.withAlpha(51),
                  color: _getScoreColor(latestAttempt.score),
                ),
                const SizedBox(height: 8),
                Text(
                  'Passing score: ${quiz.passingScore.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Correct answers: ${_getCorrectAnswersCount(latestAttempt)}/${latestAttempt.feedback.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    String statusText = status;

    switch (status) {
      case 'passed':
        backgroundColor = Colors.green;
        statusText = 'Passed';
        break;
      case 'failed':
        backgroundColor = Colors.red;
        statusText = 'Failed';
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  int _getCorrectAnswersCount(QuizAttempt attempt) {
    return attempt.feedback.where((feedback) => feedback.isCorrect).length;
  }

  Color _getScoreColor(double score) {
    if (score >= quiz.passingScore) {
      return Colors.green;
    } else if (score >= quiz.passingScore * 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}