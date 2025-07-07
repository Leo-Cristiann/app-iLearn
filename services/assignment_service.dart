import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/services/module_service.dart';
import 'dart:developer';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModuleService _moduleService = ModuleService();
  
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    try {
      final docRef = _firestore.collection('assignments').doc(assignmentId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return AssignmentModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      log('Error getting assignment: $e');
      return null;
    }
  }
  
  Future<List<AssignmentModel>> getAssignmentsForModule(String moduleId) async {
    try {
      final module = await _moduleService.getModuleById(moduleId);
      
      if (module == null) {
        return [];
      }
      
      final assignments = <AssignmentModel>[];
      
      for (var assignmentId in module.assignments) {
        final assignment = await getAssignmentById(assignmentId);
        
        if (assignment != null) {
          assignments.add(assignment);
        }
      }
      
      return assignments;
    } catch (e) {
      log('Error getting module assignments: $e');
      return [];
    }
  }
  
  Future<AssignmentModel?> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    required String moduleId,
  }) async {
    try {
      final assignmentRef = _firestore.collection('assignments').doc();
      
      final assignment = AssignmentModel(
        id: assignmentRef.id,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
      );
      
      await assignmentRef.set(assignment.toMap());
      
      // Add assignment to module
      await _moduleService.addAssignmentToModule(moduleId, assignmentRef.id);
      
      return assignment;
    } catch (e) {
      log('Error creating assignment: $e');
      return null;
    }
  }
  
  Future<bool> submitAssignment(
    String assignmentId,
    String studentId,
    String content,
  ) async {
    try {
      final submission = SubmissionData(
        content: content,
        timestamp: DateTime.now(),
      );
      
      await _firestore.collection('assignments').doc(assignmentId).update({
        'submissions.$studentId': submission.toMap(),
      });
      
      // Update student's assignments
      await _firestore.collection('users').doc(studentId).update({
        'assignments.$assignmentId': submission.toMap(),
      });
      
      return true;
    } catch (e) {
      log('Error submitting assignment: $e');
      return false;
    }
  }
  
  Future<bool> gradeSubmission(
    String assignmentId,
    String studentId,
    double grade,
    String feedback,
  ) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).update({
        'submissions.$studentId.grade': grade,
        'submissions.$studentId.feedback': feedback,
        'submissions.$studentId.status': 'graded',
      });
      
      // Update student's assignment
      await _firestore.collection('users').doc(studentId).update({
        'assignments.$assignmentId.grade': grade,
        'assignments.$assignmentId.feedback': feedback,
        'assignments.$assignmentId.status': 'graded',
      });
      
      return true;
    } catch (e) {
      log('Error grading submission: $e');
      return false;
    }
  }
}