import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/screens/student/submit_assignment_screen.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:intl/intl.dart';

class AssignmentItem extends StatelessWidget {
  final AssignmentModel assignment;
  final String studentId;
  final bool isSubmitted;
  final bool isGraded;

  const AssignmentItem({
    super.key,
    required this.assignment,
    required this.studentId,
    this.isSubmitted = false,
    this.isGraded = false,
  });

  @override
  Widget build(BuildContext context) {
    final submission = assignment.submissions[studentId];
    final dueDate = DateFormat('MMM dd, yyyy').format(assignment.dueDate);
    final isOverdue = DateTime.now().isAfter(assignment.dueDate) && !isSubmitted;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmitAssignmentScreen(
              assignment: assignment,
              readOnly: isGraded,
            ),
          ),
        );
      },
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
                  // Assignment Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSubmitted
                          ? isGraded
                              ? AppTheme.successColor.withAlpha(26)
                              : AppTheme.primaryColor.withAlpha(26)
                          : isOverdue
                              ? AppTheme.errorColor.withAlpha(26)
                              : AppTheme.warningColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        isSubmitted
                            ? isGraded
                                ? Icons.check_circle
                                : Icons.assignment_turned_in
                            : isOverdue
                                ? Icons.assignment_late
                                : Icons.assignment,
                        color: isSubmitted
                            ? isGraded
                                ? AppTheme.successColor
                                : AppTheme.primaryColor
                            : isOverdue
                                ? AppTheme.errorColor
                                : AppTheme.warningColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Assignment Title and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
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
                            // Due Date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: isOverdue
                                      ? AppTheme.errorColor
                                      : AppTheme.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Due $dueDate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue
                                        ? AppTheme.errorColor
                                        : AppTheme.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSubmitted
                                    ? isGraded
                                        ? AppTheme.successColor.withAlpha(26)
                                        : AppTheme.primaryColor.withAlpha(26)
                                    : isOverdue
                                        ? AppTheme.errorColor.withAlpha(26)
                                        : AppTheme.warningColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSubmitted
                                    ? isGraded
                                        ? 'Graded'
                                        : 'Submitted'
                                    : isOverdue
                                        ? 'Overdue'
                                        : 'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSubmitted
                                      ? isGraded
                                          ? AppTheme.successColor
                                          : AppTheme.primaryColor
                                      : isOverdue
                                          ? AppTheme.errorColor
                                          : AppTheme.warningColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Points
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isGraded
                                ? '${submission?.grade?.toInt() ?? 0}'
                                : '${assignment.maxPoints}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isGraded
                                  ? AppTheme.successColor
                                  : AppTheme.textColor,
                            ),
                          ),
                          Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 10,
                              color: isGraded
                                  ? AppTheme.successColor
                                  : AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  assignment.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (isGraded && submission?.feedback != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withAlpha(13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.successColor.withAlpha(51),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        submission?.feedback ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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