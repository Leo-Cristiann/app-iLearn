import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final List<String> contentItems;
  final List<String> quizzes;
  final List<String> assignments;
  final Map<String, bool> completionCriteria;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.contentItems = const [],
    this.quizzes = const [],
    this.assignments = const [],
    this.completionCriteria = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'contentItems': contentItems,
      'quizzes': quizzes,
      'assignments': assignments,
      'completionCriteria': completionCriteria,
    };
  }

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseId: map['courseId'] ?? '',
      contentItems: List<String>.from(map['contentItems'] ?? []),
      quizzes: List<String>.from(map['quizzes'] ?? []),
      assignments: List<String>.from(map['assignments'] ?? []),
      completionCriteria: Map<String, bool>.from(map['completionCriteria'] ?? {}),
    );
  }
}