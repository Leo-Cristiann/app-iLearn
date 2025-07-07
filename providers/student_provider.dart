import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/services/assignment_service.dart';
import 'package:project_ilearn/services/course_service.dart';
import 'package:project_ilearn/services/module_service.dart';
import 'package:project_ilearn/services/quiz_service.dart';
import 'dart:developer';

class StudentProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  final ModuleService _moduleService = ModuleService();
  final AssignmentService _assignmentService = AssignmentService();
  final QuizService _quizService = QuizService();
  
  List<CourseModel> _availableCourses = [];
  List<CourseModel> _enrolledCourses = [];
  List<AssignmentModel> _assignments = [];
  List<QuizModel> _quizzes = [];
  
  CourseModel? _selectedCourse;
  List<ModuleModel> _courseModules = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Student ID yang sedang aktif
  String? _currentStudentId;
  
  // Getters
  List<CourseModel> get availableCourses => _availableCourses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<AssignmentModel> get assignments => _assignments;
  List<QuizModel> get quizzes => _quizzes;
  CourseModel? get selectedCourse => _selectedCourse;
  List<ModuleModel> get courseModules => _courseModules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentStudentId => _currentStudentId;
  
  // Setter untuk student ID
  set currentStudentId(String? id) {
    _currentStudentId = id;
    notifyListeners();
  }
  
  // Metode untuk mendapatkan progress siswa untuk kursus tertentu
  int getStudentProgress(String courseId) {
    if (_currentStudentId == null) return 0;
    
    // Cari kursus dari daftar kursus yang terdaftar
    final course = _enrolledCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => _availableCourses.firstWhere(
        (c) => c.id == courseId,
        orElse: () => CourseModel(
          id: courseId,
          title: '',
          description: '',
          instructorId: '',
          subject: '',
        ),
      ),
    );
    
    // Cek apakah siswa terdaftar di kursus ini
    final enrollment = course.enrolledStudents[_currentStudentId];
    if (enrollment != null) {
      return enrollment.progress;
    }
    
    return 0;
  }
  
  Future<void> loadAvailableCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _availableCourses = await _courseService.getAvailableCourses();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadEnrolledCourses(String studentId) async {
    _isLoading = true;
    _error = null;
    _currentStudentId = studentId;
    notifyListeners();
    
    try {
      log("Loading enrolled courses for student: $studentId");
      
      // Get courses through CourseService
      _enrolledCourses = await _courseService.getEnrolledCourses(studentId);
      
      log("Loaded ${_enrolledCourses.length} enrolled courses");
    } catch (e) {
      _error = e.toString();
      log("Error loading enrolled courses: $_error");
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> selectCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedCourse = await _courseService.getCourseById(courseId);
      await loadCourseModules(courseId);
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadCourseModules(String courseId) async {
    try {
      _courseModules = await _moduleService.getModulesForCourse(courseId);
      
      // Load assignments and quizzes for each module
      _assignments = [];
      _quizzes = [];
      
      for (var module in _courseModules) {
        final moduleAssignments = await _assignmentService.getAssignmentsForModule(module.id);
        _assignments.addAll(moduleAssignments);
        
        final moduleQuizzes = await _quizService.getQuizzesForModule(module.id);
        _quizzes.addAll(moduleQuizzes);
      }
    } catch (e) {
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<bool> enrollCourse(String courseId, StudentModel student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _courseService.enrollStudent(courseId, student);
      
      if (result) {
        await loadEnrolledCourses(student.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> submitAssignment(String assignmentId, String studentId, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _assignmentService.submitAssignment(
        assignmentId,
        studentId,
        content,
      );
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<QuizAttempt?> attemptQuiz(
    String quizId,
    String studentId,
    Map<String, String> answers,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      log('StudentProvider: Attempting quiz: $quizId for student: $studentId');
      final attempt = await _quizService.attemptQuiz(
        quizId,
        studentId,
        answers,
      );
      
      log('StudentProvider: Quiz attempt complete, result: ${attempt != null ? 'success' : 'failure'}');
      _isLoading = false;
      notifyListeners();
      return attempt;
    } catch (e) {
      log('StudentProvider: Error attempting quiz: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  List<AssignmentModel> getPendingAssignments(String studentId) {
    return _assignments.where((assignment) {
      final submission = assignment.submissions[studentId];
      return submission == null || (submission.status != 'graded' && DateTime.now().isBefore(assignment.dueDate));
    }).toList();
  }
  
  List<AssignmentModel> getCompletedAssignments(String studentId) {
    return _assignments.where((assignment) {
      final submission = assignment.submissions[studentId];
      return submission != null && submission.status == 'graded';
    }).toList();
  }
  
  List<QuizModel> getAvailableQuizzes(String studentId) {
    return _quizzes.where((quiz) {
      final attempts = quiz.attempts[studentId] ?? [];
      return attempts.isEmpty || (attempts.isNotEmpty && attempts.last.score < quiz.passingScore);
    }).toList();
  }
  
  List<QuizModel> getCompletedQuizzes(String studentId) {
    return _quizzes.where((quiz) {
      final attempts = quiz.attempts[studentId] ?? [];
      return attempts.isNotEmpty && attempts.last.score >= quiz.passingScore;
    }).toList();
  }
}