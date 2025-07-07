import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'dart:developer';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<UserModel?> getUserById(String userId) async {
    try {
      log("UserService: Mengambil data user dengan userId: $userId");
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        log("Data user ditemukan: $data");
        
        final userType = data['userType'] as String? ?? 'student';
        log("User type: $userType");
        
        try {
          if (userType == 'student') {
            return StudentModel.fromMap(data);
          } else {
            return EducatorModel.fromMap(data);
          }
        } catch (parseError) {
          log("Error saat parsing data user: $parseError");
          
          // Fallback dengan data minimal
          if (userType == 'student') {
            return StudentModel(
              id: data['id'] ?? userId,
              username: data['username'] ?? 'Unknown',
              email: data['email'] ?? '',
              joinedDate: DateTime.now(),
            );
          } else {
            return EducatorModel(
              id: data['id'] ?? userId,
              username: data['username'] ?? 'Unknown',
              email: data['email'] ?? '',
              joinedDate: DateTime.now(),
              specialization: data['specialization'] ?? '',
            );
          }
        }
      } else {
        log("Data user tidak ditemukan untuk userId: $userId");
        return null;
      }
    } catch (e) {
      log('Error getting user: $e');
      return null;
    }
  }
  
  Future<bool> createStudent({
  required String userId,
  required String username,
  required String email,
  }) async {
    try {
      log("UserService: Membuat data student untuk userId: $userId");
      final student = StudentModel(
        id: userId,
        username: username,
        email: email,
        joinedDate: DateTime.now(),
        isActive: true,
        profileData: {},
        notifications: [],
        enrolledCourses: {},
        assignments: {},
        quizAttempts: {},
        grades: {},
        certificates: [],
        studyProgress: {},
      );
      
      // Konversi ke Map dan pastikan semua field terisi
      final userData = student.toMap();
      log("Data student yang akan disimpan: $userData");
      
      // Gunakan set() dengan merge:true untuk menghindari overwrite
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
      log("Data student berhasil disimpan");
      return true;
    } catch (e) {
      log('Error creating student: $e');
      return false;
    }
  }

  Future<bool> createEducator({
    required String userId,
    required String username,
    required String email,
    required String specialization,
  }) async {
    try {
      log("UserService: Membuat data educator untuk userId: $userId");
      final educator = EducatorModel(
        id: userId,
        username: username,
        email: email,
        joinedDate: DateTime.now(),
        isActive: true,
        specialization: specialization,
        courses: [],
        teachingHours: 0,
        ratings: [],
        profileData: {},
        notifications: [],
      );
      
      // Konversi ke Map dan pastikan semua field terisi
      final userData = educator.toMap();
      log("Data educator yang akan disimpan: $userData");
      
      // Gunakan set() dengan merge:true untuk menghindari overwrite
      await _firestore.collection('users').doc(userId).set(userData, SetOptions(merge: true));
      log("Data educator berhasil disimpan");
      return true;
    } catch (e) {
      log('Error creating educator: $e');
      return false;
    }
  }
  
  Future<bool> updateUserProfile(String userId, Map<String, String> profileData) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileData': profileData,
      });
      return true;
    } catch (e) {
      log('Error updating profile: $e');
      return false;
    }
  }
  
  Future<bool> addNotification(String userId, String title, String message) async {
    try {
      final notification = NotificationModel(
        title: title,
        message: message,
        timestamp: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(userId).update({
        'notifications': FieldValue.arrayUnion([notification.toMap()]),
      });
      return true;
    } catch (e) {
      log('Error adding notification: $e');
      return false;
    }
  }
  
  Future<bool> markNotificationAsRead(String userId, String notificationId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final notifications = List<Map<String, dynamic>>.from(data['notifications'] ?? []);
        
        for (int i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          final id = '${notification['title']}_${(notification['timestamp'] as Timestamp).toDate().millisecondsSinceEpoch}';
          
          if (id == notificationId) {
            notifications[i]['isRead'] = true;
            break;
          }
        }
        
        await docRef.update({
          'notifications': notifications,
        });
        return true;
      }
      
      return false;
    } catch (e) {
      log('Error marking notification as read: $e');
      return false;
    }
  }
}
