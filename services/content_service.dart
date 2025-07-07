import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_ilearn/models/content_model.dart';
import 'package:project_ilearn/services/module_service.dart';
import 'dart:typed_data';
import 'dart:developer';


class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ModuleService _moduleService = ModuleService();
  
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      final docRef = _firestore.collection('contents').doc(contentId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return ContentModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      log('Error getting content: $e');
      return null;
    }
  }
  
  Future<List<ContentModel>> getContentsForModule(String moduleId) async {
    try {
      final module = await _moduleService.getModuleById(moduleId);
      
      if (module == null) {
        return [];
      }
      
      final contents = <ContentModel>[];
      
      for (var contentId in module.contentItems) {
        final content = await getContentById(contentId);
        
        if (content != null) {
          contents.add(content);
        }
      }
      
      return contents;
    } catch (e) {
      log('Error getting module contents: $e');
      return [];
    }
  }
  
  Future<ContentModel?> createContent({
    required String title,
    required String contentType,
    required String content,
    required String moduleId,
    int? duration,
  }) async {
    try {
      final contentRef = _firestore.collection('contents').doc();
      
      final contentModel = ContentModel(
        id: contentRef.id,
        title: title,
        contentType: contentType,
        content: content,
        duration: duration,
      );
      
      await contentRef.set(contentModel.toMap());
      
      // Add content to module
      await _moduleService.addContentToModule(moduleId, contentRef.id);
      
      return contentModel;
    } catch (e) {
      log('Error creating content: $e');
      return null;
    }
  }
  
  Future<bool> updateContentViews(String contentId) async {
    try {
      await _firestore.collection('contents').doc(contentId).update({
        'views': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      log('Error updating content views: $e');
      return false;
    }
  }
  
  Future<bool> likeContent(String contentId) async {
    try {
      await _firestore.collection('contents').doc(contentId).update({
        'likes': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      log('Error liking content: $e');
      return false;
    }
  }
  
  Future<String?> uploadFile(String path, List<int> bytes, String contentType) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: contentType),
      );
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      log('Error uploading file: $e');
      return null;
    }
  }
}