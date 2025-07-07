import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/services/module_service.dart';
import 'dart:developer';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModuleService _moduleService = ModuleService();
  
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final docRef = _firestore.collection('quizzes').doc(quizId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return QuizModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      log('Error getting quiz: $e');
      return null;
    }
  }
  
  Future<List<QuizModel>> getQuizzesForModule(String moduleId) async {
    try {
      final module = await _moduleService.getModuleById(moduleId);
      
      if (module == null) {
        return [];
      }
      
      final quizzes = <QuizModel>[];
      
      for (var quizId in module.quizzes) {
        final quiz = await getQuizById(quizId);
        
        if (quiz != null) {
          quizzes.add(quiz);
        }
      }
      
      return quizzes;
    } catch (e) {
      log('Error getting module quizzes: $e');
      return [];
    }
  }
  
  Future<QuizModel?> createQuiz({
    required String title,
    required String description,
    required int timeLimit,
    required double passingScore,
    required String moduleId,
    required List<QuestionModel> questions,
  }) async {
    try {
      final quizRef = _firestore.collection('quizzes').doc();
      
      final quiz = QuizModel(
        id: quizRef.id,
        title: title,
        description: description,
        timeLimit: timeLimit,
        passingScore: passingScore,
        questions: questions,
      );
      
      await quizRef.set(quiz.toMap());
      
      // Add quiz to module
      await _moduleService.addQuizToModule(moduleId, quizRef.id);
      
      return quiz;
    } catch (e) {
      log('Error creating quiz: $e');
      return null;
    }
  }
  
  Future<QuizAttempt?> attemptQuiz(
    String quizId,
    String studentId,
    Map<String, String> answers,
  ) async {
    try {
      log('Starting quiz attempt for quiz: $quizId by student: $studentId');
      // First, get the current quiz data
      final quiz = await getQuizById(quizId);
      
      if (quiz == null) {
        log('Quiz not found: $quizId');
        return null;
      }
      
      // Calculate score and generate feedback
      double totalPoints = 0;
      double earnedPoints = 0;
      final feedback = <QuestionFeedback>[];
      
      for (var question in quiz.questions) {
        totalPoints += question.points.toDouble();
        final answer = answers[question.id];
        
        final isCorrect = answer == question.correctAnswer;
        
        if (isCorrect) {
          earnedPoints += question.points.toDouble();
        }
        
        feedback.add(
          QuestionFeedback(
            questionId: question.id,
            questionText: question.text,
            isCorrect: isCorrect,
            explanation: question.explanation,
          ),
        );
      }
      
      final score = totalPoints > 0 ? ((earnedPoints / totalPoints) * 100).toDouble() : 0.0;
      
      final attempt = QuizAttempt(
        timestamp: DateTime.now(),
        answers: answers,
        score: score,
        feedback: feedback,
      );
      
      final attemptMap = attempt.toMap();
      log('Attempt prepared with score: $score');
      
      // Bypass transaction and use regular updates for now to simplify
      try {
        // 1. Update quiz document
        final quizRef = _firestore.collection('quizzes').doc(quizId);
        final quizDoc = await quizRef.get();
        
        if (!quizDoc.exists) {
          log('Quiz document no longer exists');
          throw Exception('Quiz no longer exists');
        }
        
        Map<String, dynamic> attemptsData = {};
        
        try {
          final quizData = quizDoc.data() as Map<String, dynamic>;
          attemptsData = Map<String, dynamic>.from(quizData['attempts'] ?? {});
        } catch (e) {
          log('Error accessing attempts data: $e');
          // Create fresh attempts map if there's an error
          attemptsData = {};
        }
        
        // Update the quiz attempts - careful with the data structure
        if (attemptsData.containsKey(studentId)) {
          // Get the existing attempts and add the new one
          List<dynamic> existingAttempts = attemptsData[studentId] ?? [];
          existingAttempts.add(attemptMap);
          attemptsData[studentId] = existingAttempts;
        } else {
          // Create a new list with just this attempt
          attemptsData[studentId] = [attemptMap];
        }
        
        // Update the quiz document
        await quizRef.update({'attempts': attemptsData});
        log('Quiz document updated successfully');
        
        // 2. Update student document separately
        try {
          final studentRef = _firestore.collection('users').doc(studentId);
          final studentDoc = await studentRef.get();
          
          if (studentDoc.exists) {
            Map<String, dynamic> quizAttemptsData = {};
            
            try {
              final studentData = studentDoc.data() as Map<String, dynamic>;
              quizAttemptsData = Map<String, dynamic>.from(studentData['quizAttempts'] ?? {});
            } catch (e) {
              log('Error accessing student quizAttempts: $e');
              // Create fresh quizAttempts map if there's an error
              quizAttemptsData = {};
            }
            
            // Update the student's quiz attempts
            if (quizAttemptsData.containsKey(quizId)) {
              // Get existing attempts and add the new one
              List<dynamic> existingAttempts = quizAttemptsData[quizId] ?? [];
              existingAttempts.add(attemptMap);
              quizAttemptsData[quizId] = existingAttempts;
            } else {
              // Create a new list with just this attempt
              quizAttemptsData[quizId] = [attemptMap];
            }
            
            // Update the student document
            await studentRef.update({'quizAttempts': quizAttemptsData});
            log('Student document updated successfully');
          } else {
            log('Student document not found, skipping student update');
          }
        } catch (studentError) {
          log('Error updating student document: $studentError');
          // Continue even if student update fails, since quiz update succeeded
        }
        
        // If we get here, at least the quiz was updated
        log('Quiz attempt process completed');
        return attempt;
      } catch (updateError) {
        log('Error during update: $updateError');
        throw Exception('Failed to save quiz attempt: $updateError');
      }
    } catch (e) {
      log('Error attempting quiz: $e');
      throw Exception('Failed to process quiz attempt: $e');
    }
  }
}