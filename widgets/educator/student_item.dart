import 'package:flutter/material.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:intl/intl.dart';

class StudentItem extends StatelessWidget {
  final StudentModel student;
  final Map<String, EnrollmentData>? enrollmentData;
  final VoidCallback onTap;

  const StudentItem({
    super.key,
    required this.student,
    this.enrollmentData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enrollment = enrollmentData?[student.id];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
                child: Text(
                  student.username.isNotEmpty ? student.username[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.username,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (enrollment != null) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(context, enrollment.status),
                    const SizedBox(height: 8),
                    Text(
                      'Joined: ${DateFormat('MMM dd, yyyy').format(enrollment.date)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pie_chart,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Progress: ${enrollment.progress}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
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
    Color textColor = Colors.white;

    switch (status) {
      case 'active':
        backgroundColor = Colors.green;
        break;
      case 'inactive':
        backgroundColor = Colors.orange;
        break;
      case 'completed':
        backgroundColor = Colors.blue;
        break;
      case 'dropped':
        backgroundColor = Colors.red;
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
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}