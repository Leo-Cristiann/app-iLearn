import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_ilearn/models/course_model.dart';

class CourseAnalyticsCard extends StatelessWidget {
  final CourseModel course;

  const CourseAnalyticsCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final enrolledCount = course.enrolledStudents.length;
    final maxStudents = course.maxStudents;
    
    // Calculate progress data
    int totalProgress = 0;
    int completedCount = 0;
    final progressDistribution = {
      "0-20": 0,
      "21-40": 0,
      "41-60": 0,
      "61-80": 0,
      "81-100": 0,
    };
    
    for (var enrollment in course.enrolledStudents.values) {
      totalProgress += enrollment.progress;
      
      if (enrollment.progress == 100) {
        completedCount++;
      }
      
      // Add to progress distribution
      if (enrollment.progress <= 20) {
        progressDistribution["0-20"] = (progressDistribution["0-20"] ?? 0) + 1;
      } else if (enrollment.progress <= 40) {
        progressDistribution["21-40"] = (progressDistribution["21-40"] ?? 0) + 1;
      } else if (enrollment.progress <= 60) {
        progressDistribution["41-60"] = (progressDistribution["41-60"] ?? 0) + 1;
      } else if (enrollment.progress <= 80) {
        progressDistribution["61-80"] = (progressDistribution["61-80"] ?? 0) + 1;
      } else {
        progressDistribution["81-100"] = (progressDistribution["81-100"] ?? 0) + 1;
      }
    }
    
    final avgProgress = enrolledCount > 0 ? totalProgress / enrolledCount : 0;
    final completionRate = enrolledCount > 0 ? completedCount / enrolledCount : 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  context,
                  Icons.people,
                  '$enrolledCount/$maxStudents',
                  'Students',
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  Icons.pie_chart,
                  '${avgProgress.toStringAsFixed(1)}%',
                  'Avg. Progress',
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  Icons.check_circle,
                  '${(completionRate * 100).toStringAsFixed(1)}%',
                  'Completion',
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Student Progress Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxStudents.toDouble(),
                  barGroups: [
                    _buildBarGroup(
                      0, 
                      progressDistribution["0-20"]?.toDouble() ?? 0, 
                      Colors.red
                    ),
                    _buildBarGroup(
                      1, 
                      progressDistribution["21-40"]?.toDouble() ?? 0, 
                      Colors.orange
                    ),
                    _buildBarGroup(
                      2, 
                      progressDistribution["41-60"]?.toDouble() ?? 0, 
                      Colors.yellow
                    ),
                    _buildBarGroup(
                      3, 
                      progressDistribution["61-80"]?.toDouble() ?? 0, 
                      Colors.lightGreen
                    ),
                    _buildBarGroup(
                      4, 
                      progressDistribution["81-100"]?.toDouble() ?? 0, 
                      Colors.green
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['0-20%', '21-40%', '41-60%', '61-80%', '81-100%'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 != 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withAlpha(51),
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}