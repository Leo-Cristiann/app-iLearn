import 'package:flutter/material.dart';
import 'package:project_ilearn/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final bool isEnrolled;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.dividerColor.withAlpha(128),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image/thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: course.thumbnail.isNotEmpty
                  ? Image.network(
                      course.thumbnail,
                      height: 150.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
                    )
                  : _buildDefaultImage(),
            ),
            
            // Course info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      course.subject,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Course title
                  Text(
                    course.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Course description
                  Text(
                    course.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Course info and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Students enrolled
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16.0,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '${course.enrolledStudents.length}/${course.maxStudents}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      
                      // Course status/rating
                      if (isEnrolled) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16.0,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              course.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: course.status == 'active'
                                ? Colors.green[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            course.status == 'active' ? 'Active' : 'Coming Soon',
                            style: TextStyle(
                              color: course.status == 'active'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      height: 150.0,
      width: double.infinity,
      color: Colors.blueGrey[100],
      child: Center(
        child: Icon(
          Icons.school,
          size: 50.0,
          color: Colors.blueGrey[400],
        ),
      ),
    );
  }
}