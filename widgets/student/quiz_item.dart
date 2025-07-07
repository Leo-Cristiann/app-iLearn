import 'package:flutter/material.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/utils/app_theme.dart';

class QuizItem extends StatelessWidget {
  final QuizModel quiz;
  final String studentId;
  final VoidCallback onTap;

  const QuizItem({
    super.key,
    required this.quiz,
    required this.studentId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final attempts = quiz.attempts[studentId] ?? [];
    final hasAttempted = attempts.isNotEmpty;
    final latestAttempt = hasAttempted ? attempts.last : null;
    final score = latestAttempt?.score ?? 0;
    final passed = score >= quiz.passingScore;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Quiz Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasAttempted
                          ? passed
                              ? AppTheme.successColor.withAlpha(26)
                              : AppTheme.errorColor.withAlpha(26)
                          : AppTheme.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        hasAttempted
                            ? passed
                                ? Icons.check_circle
                                : Icons.close
                            : Icons.quiz,
                        color: hasAttempted
                            ? passed
                                ? AppTheme.successColor
                                : AppTheme.errorColor
                            : AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quiz Title and Time Limit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Time Limit
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${quiz.timeLimit} min',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Questions Count
                            Row(
                              children: [
                                const Icon(
                                  Icons.help,
                                  size: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${quiz.questions.length} Questions',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score
                  if (hasAttempted)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: passed
                            ? AppTheme.successColor.withAlpha(26)
                            : AppTheme.errorColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${score.toInt()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: passed
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                fontSize: 10,
                                color: passed
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (quiz.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // Passing Score and Attempt Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Passing score:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.passingScore.toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasAttempted
                          ? passed
                              ? AppTheme.successColor
                              : AppTheme.primaryColor
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      hasAttempted
                          ? passed
                              ? 'Review'
                              : 'Try Again'
                          : 'Start Quiz',
                    ),
                  ),
                ],
              ),
              if (hasAttempted) ...[
                const SizedBox(height: 8),
                // Attempts History
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attempts:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: attempts.length,
                          itemBuilder: (context, index) {
                            final attempt = attempts[index];
                            final attemptScore = attempt.score;
                            final attemptPassed = attemptScore >= quiz.passingScore;
                            
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: attemptPassed
                                    ? AppTheme.successColor.withAlpha(26)
                                    : AppTheme.errorColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: attemptPassed
                                      ? AppTheme.successColor.withAlpha(77)
                                      : AppTheme.errorColor.withAlpha(77),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Attempt ${index + 1}: ${attemptScore.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: attemptPassed
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}