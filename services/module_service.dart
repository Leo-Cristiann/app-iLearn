import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'dart:developer';

class ModuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<ModuleModel?> getModuleById(String moduleId) async {
    try {
      final docRef = _firestore.collection('modules').doc(moduleId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return ModuleModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      log('Error getting module: $e');
      return null;
    }
  }
  
  Future<List<ModuleModel>> getModulesForCourse(String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('modules')
          .where('courseId', isEqualTo: courseId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ModuleModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('Error getting course modules: $e');
      return [];
    }
  }
  
  Future<ModuleModel?> createModule({
    required String title,
    required String description,
    required String courseId,
  }) async {
    try {
      final moduleRef = _firestore.collection('modules').doc();
      
      final module = ModuleModel(
        id: moduleRef.id,
        title: title,
        description: description,
        courseId: courseId,
      );
      
      await moduleRef.set(module.toMap());
      
      // Update course's modules list
      await _firestore.collection('courses').doc(courseId).update({
        'modules': FieldValue.arrayUnion([moduleRef.id]),
      });
      
      return module;
    } catch (e) {
      log('Error creating module: $e');
      return null;
    }
  }
  
  Future<bool> updateModule(ModuleModel module) async {
    try {
      await _firestore.collection('modules').doc(module.id).update(module.toMap());
      return true;
    } catch (e) {
      log('Error updating module: $e');
      return false;
    }
  }
  
  Future<bool> addContentToModule(String moduleId, String contentId) async {
    try {
      await _firestore.collection('modules').doc(moduleId).update({
        'contentItems': FieldValue.arrayUnion([contentId]),
      });
      return true;
    } catch (e) {
      log('Error adding content to module: $e');
      return false;
    }
  }
  
  Future<bool> addQuizToModule(String moduleId, String quizId) async {
    try {
      await _firestore.collection('modules').doc(moduleId).update({
        'quizzes': FieldValue.arrayUnion([quizId]),
      });
      return true;
    } catch (e) {
      log('Error adding quiz to module: $e');
      return false;
    }
  }
  
  Future<bool> addAssignmentToModule(String moduleId, String assignmentId) async {
    try {
      await _firestore.collection('modules').doc(moduleId).update({
        'assignments': FieldValue.arrayUnion([assignmentId]),
      });
      return true;
    } catch (e) {
      log('Error adding assignment to module: $e');
      return false;
    }
  }
}
