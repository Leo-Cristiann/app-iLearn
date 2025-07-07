import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final int maxStudents;
  final String status;
  final List<String> modules;
  final Map<String, EnrollmentData> enrolledStudents;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> prerequisites;
  final List<CommentModel> comments;
  final List<AnnouncementModel> announcements;
  final double rating;
  final List<CourseReviewModel> reviews;
  final CourseClassModel? courseClass;
  final String subject;
  final String thumbnail;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    this.maxStudents = 50,
    this.status = 'draft',
    this.modules = const [],
    this.enrolledStudents = const {},
    this.startDate,
    this.endDate,
    this.prerequisites = const [],
    this.comments = const [],
    this.announcements = const [],
    this.rating = 0.0,
    this.reviews = const [],
    this.courseClass,
    required this.subject,
    this.thumbnail = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'maxStudents': maxStudents,
      'status': status,
      'modules': modules,
      'enrolledStudents': enrolledStudents.map((key, value) => MapEntry(key, value.toMap())),
      'startDate': startDate,
      'endDate': endDate,
      'prerequisites': prerequisites,
      'comments': comments.map((x) => x.toMap()).toList(),
      'announcements': announcements.map((x) => x.toMap()).toList(),
      'rating': rating,
      'reviews': reviews.map((x) => x.toMap()).toList(),
      'courseClass': courseClass?.toMap(),
      'subject': subject,
      'thumbnail': thumbnail,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructorId: map['instructorId'] ?? '',
      maxStudents: map['maxStudents'] ?? 50,
      status: map['status'] ?? 'draft',
      modules: List<String>.from(map['modules'] ?? []),
      enrolledStudents: (map['enrolledStudents'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              EnrollmentData.fromMap(value),
            ),
          ) ??
          {},
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      prerequisites: List<String>.from(map['prerequisites'] ?? []),
      comments: List<CommentModel>.from(
        (map['comments'] ?? []).map(
          (x) => CommentModel.fromMap(x),
        ),
      ),
      announcements: List<AnnouncementModel>.from(
        (map['announcements'] ?? []).map(
          (x) => AnnouncementModel.fromMap(x),
        ),
      ),
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: List<CourseReviewModel>.from(
        (map['reviews'] ?? []).map(
          (x) => CourseReviewModel.fromMap(x),
        ),
      ),
      courseClass: map['courseClass'] != null
          ? CourseClassModel.fromMap(map['courseClass'])
          : null,
      subject: map['subject'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
    );
  }
}

class CourseClassModel {
  final String type;
  final String meetingUrl;
  final String classroom;
  final String day;
  final String time;

  CourseClassModel({
    required this.type,
    this.meetingUrl = '',
    this.classroom = '',
    required this.day,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'meetingUrl': meetingUrl,
      'classroom': classroom,
      'day': day,
      'time': time,
    };
  }

  factory CourseClassModel.fromMap(Map<String, dynamic> map) {
    return CourseClassModel(
      type: map['type'] ?? '',
      meetingUrl: map['meetingUrl'] ?? '',
      classroom: map['classroom'] ?? '',
      day: map['day'] ?? '',
      time: map['time'] ?? '',
    );
  }
}

class CommentModel {
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<CommentModel> replies;

  CommentModel({
    required this.userId,
    required this.content,
    required this.timestamp,
    this.replies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
      'replies': replies.map((x) => x.toMap()).toList(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      replies: List<CommentModel>.from(
        (map['replies'] ?? []).map(
          (x) => CommentModel.fromMap(x),
        ),
      ),
    );
  }
}

class AnnouncementModel {
  final String title;
  final String content;
  final DateTime timestamp;
  final String authorId;

  AnnouncementModel({
    required this.title,
    required this.content,
    required this.timestamp,
    required this.authorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'authorId': authorId,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      authorId: map['authorId'] ?? '',
    );
  }
}

class CourseReviewModel {
  final String studentId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  CourseReviewModel({
    required this.studentId,
    required this.rating,
    this.comment = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory CourseReviewModel.fromMap(Map<String, dynamic> map) {
    return CourseReviewModel(
      studentId: map['studentId'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}