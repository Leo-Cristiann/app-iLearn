import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';

class QuizManagementItem extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onViewResults;

  const QuizManagementItem({
    super.key,
    required this.quiz,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final totalAttempts = quiz.attempts.isEmpty
        ? 0
        : quiz.attempts.values.fold<int>(
            0, (prev, attempts) => prev + attempts.length);
            
    final hasAttempts = totalAttempts > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onViewResults,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasAttempts ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasAttempts ? 'Has Attempts' : 'No Attempts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuizInfo(
                    context,
                    Icons.help_outline,
                    '${quiz.questions.length}',
                    'Questions',
                  ),
                  _buildQuizInfo(
                    context,
                    Icons.timer,
                    '${quiz.timeLimit} min',
                    'Time Limit',
                  ),
                  _buildQuizInfo(
                    context,
                    Icons.people,
                    '$totalAttempts',
                    'Attempts',
                  ),
                  _buildQuizInfo(
                    context,
                    Icons.score,
                    '${quiz.passingScore}%',
                    'Passing Score',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onViewResults,
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Results'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInfo(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}