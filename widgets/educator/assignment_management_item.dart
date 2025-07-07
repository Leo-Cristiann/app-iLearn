import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:intl/intl.dart';

class AssignmentManagementItem extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;

  const AssignmentManagementItem({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final submissionCount = assignment.submissions.length;
    final gradedCount = assignment.submissions.values
        .where((submission) => submission.status.toLowerCase() == 'graded')
        .length;
    final pendingCount = submissionCount - gradedCount;

    final dateFormat = DateFormat('MMM dd, yyyy');
    final dueDateString = dateFormat.format(assignment.dueDate);
    final isOverdue = assignment.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverdue
                            ? AppTheme.errorColor
                            : AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: $dueDateString',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue
                              ? AppTheme.errorColor
                              : AppTheme.secondaryTextColor,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$submissionCount submissions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: pendingCount > 0
                              ? AppTheme.warningColor
                              : AppTheme.successColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pendingCount > 0 ? '$pendingCount pending' : 'All graded',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: pendingCount > 0
                                  ? AppTheme.warningColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}