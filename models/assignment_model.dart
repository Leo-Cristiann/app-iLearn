import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; 
import 'course_model.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxPoints;
  final Map<String, SubmissionData> submissions;
  final Map<String, int> rubric;
  final List<CommentModel> comments;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.maxPoints = 100,
    this.submissions = const {},
    this.rubric = const {},
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'maxPoints': maxPoints,
      'submissions': submissions.map((key, value) => MapEntry(key, value.toMap())),
      'rubric': rubric,
      'comments': comments.map((x) => x.toMap()).toList(),
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      maxPoints: map['maxPoints'] ?? 100,
      submissions: (map['submissions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              SubmissionData.fromMap(value),
            ),
          ) ??
          {},
      rubric: Map<String, int>.from(map['rubric'] ?? {}),
      comments: List<CommentModel>.from(
        (map['comments'] ?? []).map(
          (x) => CommentModel.fromMap(x),
        ),
      ),
    );
  }
}