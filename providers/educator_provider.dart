import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/services/assignment_service.dart';
import 'package:project_ilearn/services/content_service.dart';
import 'package:project_ilearn/services/course_service.dart';
import 'package:project_ilearn/services/module_service.dart';
import 'package:project_ilearn/services/quiz_service.dart';
import 'package:project_ilearn/services/user_service.dart';

class EducatorProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  final ModuleService _moduleService = ModuleService();
  final AssignmentService _assignmentService = AssignmentService();
  final QuizService _quizService = QuizService();
  final UserService _userService = UserService();
  final ContentService _contentService = ContentService(); 
  
  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  List<ModuleModel> _courseModules = [];
  List<StudentModel> _enrolledStudents = [];
  List<AssignmentModel> _assignments = [];
  List<QuizModel> _quizzes = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
  List<ModuleModel> get courseModules => _courseModules;
  List<StudentModel> get enrolledStudents => _enrolledStudents;
  List<AssignmentModel> get assignments => _assignments;
  List<QuizModel> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadEducatorCourses(String educatorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _courses = await _courseService.getCoursesByInstructor(educatorId);
    } catch (e) {
      _error = e.toString();
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
      await loadEnrolledStudents(courseId);
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
  
  Future<void> loadEnrolledStudents(String courseId) async {
    try {
      final course = await _courseService.getCourseById(courseId);
      
      if (course != null) {
        _enrolledStudents = [];
        
        for (var studentId in course.enrolledStudents.keys) {
          final student = await _userService.getUserById(studentId);
          
          if (student != null && student is StudentModel) {
            _enrolledStudents.add(student);
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<bool> createCourse(
    String title,
    String description,
    String subject,
    int maxStudents,
    String educatorId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newCourse = await _courseService.createCourse(
        title: title,
        description: description,
        subject: subject,
        maxStudents: maxStudents,
        instructorId: educatorId,
      );
      
      if (newCourse != null) {
        await loadEducatorCourses(educatorId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to create course';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateCourse(CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _courseService.updateCourse(course);
      
      if (result) {
        _selectedCourse = course;
        await loadEducatorCourses(course.instructorId);
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
  
  Future<bool> publishCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _courseService.publishCourse(courseId);
      
      if (result && _selectedCourse != null) {
        await loadEducatorCourses(_selectedCourse!.instructorId);
        await selectCourse(courseId);
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
  
  Future<ModuleModel?> addModuleToCourse(
    String courseId,
    String title,
    String description,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final module = await _moduleService.createModule(
        title: title,
        description: description,
        courseId: courseId,
      );
      
      if (module != null) {
        await loadCourseModules(courseId);
      }
      
      _isLoading = false;
      notifyListeners();
      return module;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<AssignmentModel?> createAssignment(
    String moduleId,
    String title,
    String description,
    DateTime dueDate,
    int maxPoints,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final assignment = await _assignmentService.createAssignment(
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
        moduleId: moduleId,
      );
      
      if (assignment != null && _selectedCourse != null) {
        await loadCourseModules(_selectedCourse!.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return assignment;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<QuizModel?> createQuiz(
    String moduleId,
    String title,
    String description,
    int timeLimit,
    double passingScore,
    List<QuestionModel> questions,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final quiz = await _quizService.createQuiz(
        title: title,
        description: description,
        timeLimit: timeLimit,
        passingScore: passingScore,
        moduleId: moduleId,
        questions: questions,
      );
      
      if (quiz != null && _selectedCourse != null) {
        await loadCourseModules(_selectedCourse!.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return quiz;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<bool> gradeAssignment(
    String assignmentId,
    String studentId,
    double grade,
    String feedback,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _assignmentService.gradeSubmission(
        assignmentId,
        studentId,
        grade,
        feedback,
      );
      
      if (result && _selectedCourse != null) {
        await loadCourseModules(_selectedCourse!.id);
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
  
  // Metode untuk menambahkan konten ke modul
  Future<bool> addContentToModule(
    String moduleId,
    String title,
    String contentType,
    String content,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simpan konten menggunakan ContentService
      final createdContent = await _contentService.createContent(
        title: title, 
        contentType: contentType, 
        content: content,
        moduleId: moduleId,
        duration: contentType == 'video' ? 0 : null,
      );
      
      // Refresh data modul jika ada course yang dipilih
      if (createdContent != null && _selectedCourse != null) {
        await loadCourseModules(_selectedCourse!.id);
      }
      
      _isLoading = false;
      notifyListeners();
      return createdContent != null; // Return true jika content berhasil dibuat
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  List<AssignmentModel> getPendingAssignments() {
    final pendingAssignments = <AssignmentModel>[];
    
    for (var assignment in _assignments) {
      for (var submission in assignment.submissions.entries) {
        if (submission.value.status == 'submitted') {
          pendingAssignments.add(assignment);
          break;
        }
      }
    }
    
    return pendingAssignments;
  }
  
  Map<String, dynamic> getCourseAnalytics() {
    if (_selectedCourse == null) {
      return {};
    }
    
    final enrolledCount = _selectedCourse!.enrolledStudents.length;
    
    int totalProgress = 0;
    int completedCount = 0;
    
    for (var enrollment in _selectedCourse!.enrolledStudents.values) {
      totalProgress += enrollment.progress;
      
      if (enrollment.progress == 100) {
        completedCount++;
      }
    }
    
    final averageProgress = enrolledCount > 0 ? totalProgress / enrolledCount : 0;
    final completionRate = enrolledCount > 0 ? completedCount / enrolledCount : 0;
    
    return {
      'enrolledCount': enrolledCount,
      'averageProgress': averageProgress,
      'completionRate': completionRate,
    };
  }
}