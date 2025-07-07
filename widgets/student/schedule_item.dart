import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleItem extends StatelessWidget {
  final CourseModel course;
  final DateTime? date;

  const ScheduleItem({
    super.key,
    required this.course,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Check if course has class schedule
    if (course.courseClass == null) {
      return const SizedBox();
    }

    final courseClass = course.courseClass!;
    final isToday = date == null
        ? false
        : DateFormat('EEEE').format(date!).toLowerCase() ==
            courseClass.day.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.primaryColor.withAlpha(13)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(
                color: AppTheme.primaryColor.withAlpha(77),
                width: 1.5,
              )
            : null,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.primaryColor.withAlpha(26)
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    courseClass.time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    courseClass.day,
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday
                          ? AppTheme.primaryColor
                          : AppTheme.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Course Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Class Type
                  Row(
                    children: [
                      Icon(
                        courseClass.type.toLowerCase() == 'synchronous'
                            ? Icons.videocam
                            : Icons.location_on,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        courseClass.type,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location or Meeting Link
                  courseClass.type.toLowerCase() == 'synchronous'
                      ? GestureDetector(
                          onTap: () async {
                            final url = courseClass.meetingUrl;
                            if (url.isNotEmpty) {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Join Meeting',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          'Location: ${courseClass.classroom}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textColor,
                          ),
                        ),
                ],
              ),
            ),
            // Today Indicator
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}