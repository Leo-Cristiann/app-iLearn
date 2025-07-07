import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class QuizModel {
  final String id;
  final String title;
  final String description;
  final int timeLimit;
  final List<QuestionModel> questions;
  final Map<String, List<QuizAttempt>> attempts;
  final double passingScore;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    this.timeLimit = 60,
    this.questions = const [],
    this.attempts = const {},
    this.passingScore = 70.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeLimit': timeLimit,
      'questions': questions.map((x) => x.toMap()).toList(),
      'attempts': attempts.map(
        (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
      ),
      'passingScore': passingScore,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timeLimit: map['timeLimit'] ?? 60,
      questions: List<QuestionModel>.from(
        (map['questions'] ?? []).map(
          (x) => QuestionModel.fromMap(x),
        ),
      ),
      attempts: (map['attempts'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              List<QuizAttempt>.from(
                (value as List).map(
                  (x) => QuizAttempt.fromMap(x),
                ),
              ),
            ),
          ) ??
          {},
      passingScore: map['passingScore']?.toDouble() ?? 70.0,
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final String correctAnswer;
  final int points;
  final String questionType;
  final List<String> options;
  final String explanation;

  QuestionModel({
    required this.id,
    required this.text,
    required this.correctAnswer,
    this.points = 1,
    this.questionType = 'multiple_choice',
    this.options = const [],
    this.explanation = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'correctAnswer': correctAnswer,
      'points': points,
      'questionType': questionType,
      'options': options,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      points: map['points'] ?? 1,
      questionType: map['questionType'] ?? 'multiple_choice',
      options: List<String>.from(map['options'] ?? []),
      explanation: map['explanation'] ?? '',
    );
  }
}