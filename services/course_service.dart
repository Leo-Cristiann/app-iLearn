import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'dart:developer';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final docRef = _firestore.collection('courses').doc(courseId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return CourseModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      log('Error getting course: $e');
      return null;
    }
  }
  
  Future<List<CourseModel>> getAvailableCourses() async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .where('status', isEqualTo: 'active')
          .get();
      
      return querySnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('Error getting available courses: $e');
      return [];
    }
  }
  
  Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    try {
      log("Getting enrolled courses for student $studentId");
      final List<CourseModel> courses = [];
      
      // Get course IDs through query
      final querySnapshot = await _firestore
          .collection('courses')
          .where('enrolledStudents.$studentId', isNull: false)
          .get();
      
      log("Found ${querySnapshot.docs.length} courses where student is enrolled");
      
      for (var doc in querySnapshot.docs) {
        final courseData = doc.data();
        
        try {
          final course = CourseModel.fromMap(courseData);
          courses.add(course);
        } catch (e) {
          log("Error parsing course: $e");
        }
      }
      
      return courses;
    } catch (e) {
      log('Error getting enrolled courses: $e');
      return [];
    }
  }
  
  Future<List<CourseModel>> getCoursesByInstructor(String instructorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .where('instructorId', isEqualTo: instructorId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('Error getting instructor courses: $e');
      return [];
    }
  }
  
  Future<CourseModel?> createCourse({
    required String title,
    required String description,
    required String subject,
    required int maxStudents,
    required String instructorId,
  }) async {
    try {
      final courseRef = _firestore.collection('courses').doc();
      
      final course = CourseModel(
        id: courseRef.id,
        title: title,
        description: description,
        instructorId: instructorId,
        maxStudents: maxStudents,
        subject: subject,
      );
      
      await courseRef.set(course.toMap());
      
      // Update instructor's courses list
      await _firestore.collection('users').doc(instructorId).update({
        'courses': FieldValue.arrayUnion([courseRef.id]),
      });
      
      return course;
    } catch (e) {
      log('Error creating course: $e');
      return null;
    }
  }
  
  Future<bool> updateCourse(CourseModel course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(course.toMap());
      return true;
    } catch (e) {
      log('Error updating course: $e');
      return false;
    }
  }
  
  Future<bool> publishCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'status': 'active',
        'startDate': DateTime.now(),
      });
      return true;
    } catch (e) {
      log('Error publishing course: $e');
      return false;
    }
  }
  
  Future<bool> enrollStudent(String courseId, StudentModel student) async {
    try {
      log("Enrolling student ${student.id} to course $courseId");
      
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      
      if (!courseDoc.exists) {
        return false;
      }
      
      final courseData = courseDoc.data() as Map<String, dynamic>;
      final enrolledStudents = Map<String, dynamic>.from(courseData['enrolledStudents'] ?? {});
      
      if (enrolledStudents.length >= (courseData['maxStudents'] ?? 50)) {
        return false;
      }
      
      if (enrolledStudents.containsKey(student.id)) {
        return false;
      }
      
      final enrollmentData = EnrollmentData(
        date: DateTime.now(),
        lastAccessed: DateTime.now(),
      );
      
      // Update course's enrolled students
      await _firestore.collection('courses').doc(courseId).update({
        'enrolledStudents.${student.id}': enrollmentData.toMap(),
      });
      
      // Update student's enrolled courses
      await _firestore.collection('users').doc(student.id).update({
        'enrolledCourses.$courseId': enrollmentData.toMap(),
      });
      
      log("Successfully enrolled student in course");
      return true;
    } catch (e) {
      log('Error enrolling student: $e');
      return false;
    }
  }
}