import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

abstract class UserModel {
  final String id;
  final String username;
  final String email;
  final DateTime joinedDate;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, String> profileData;
  final List<NotificationModel> notifications;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.joinedDate,
    this.lastLogin,
    this.isActive = true,
    this.profileData = const {},
    this.notifications = const [],
  });

  Map<String, dynamic> toMap();
  
  String get userType;

  factory UserModel.fromMap(Map<String, dynamic> map, String type) {
    try {
      log("UserModel.fromMap dipanggil dengan type: $type");
      log("Map data: $map");
      
      if (type == 'student') {
        return StudentModel.fromMap(map);
      } else {
        return EducatorModel.fromMap(map);
      }
    } catch (e) {
      log("Error di UserModel.fromMap: $e");
      // Fallback untuk menghindari crash
      if (type == 'student') {
        return StudentModel(
          id: map['id'] ?? 'unknown',
          username: map['username'] ?? 'Unknown User',
          email: map['email'] ?? 'no-email',
          joinedDate: DateTime.now(),
        );
      } else {
        return EducatorModel(
          id: map['id'] ?? 'unknown',
          username: map['username'] ?? 'Unknown User',
          email: map['email'] ?? 'no-email',
          joinedDate: DateTime.now(),
          specialization: '',
        );
      }
    }
  }
}

class NotificationModel {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      return NotificationModel(
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        timestamp: map['timestamp'] != null 
            ? parseDateTime(map['timestamp'])
            : DateTime.now(),
        isRead: map['isRead'] ?? false,
      );
    } catch (e) {
      log("Error parsing NotificationModel: $e");
      return NotificationModel(
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        timestamp: DateTime.now(),
      );
    }
  }
}

class StudentModel extends UserModel {
  final Map<String, EnrollmentData> enrolledCourses;
  final Map<String, SubmissionData> assignments;
  final Map<String, List<QuizAttempt>> quizAttempts;
  final Map<String, GradeData> grades;
  final List<String> certificates;
  final Map<String, int> studyProgress;

  StudentModel({
    required super.id,
    required super.username,
    required super.email,
    required super.joinedDate,
    super.lastLogin,
    super.isActive,
    super.profileData,
    super.notifications,
    this.enrolledCourses = const {},
    this.assignments = const {},
    this.quizAttempts = const {},
    this.grades = const {},
    this.certificates = const [],
    this.studyProgress = const {},
  });

  @override
  String get userType => 'student';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'joinedDate': joinedDate,
      'lastLogin': lastLogin,
      'isActive': isActive,
      'profileData': profileData,
      'notifications': notifications.map((e) => e.toMap()).toList(),
      'userType': userType,
      'enrolledCourses': enrolledCourses.map((key, value) => MapEntry(key, value.toMap())),
      'assignments': assignments.map((key, value) => MapEntry(key, value.toMap())),
      'quizAttempts': quizAttempts.map(
        (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
      ),
      'grades': grades.map((key, value) => MapEntry(key, value.toMap())),
      'certificates': certificates,
      'studyProgress': studyProgress,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    try {
      log("StudentModel.fromMap parsing data");
      
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      // Helper function untuk parse Map
      Map<String, String> parseProfileData(dynamic value) {
        if (value == null) return {};
        if (value is Map<String, String>) {
          return value;
        } else if (value is Map<String, dynamic>) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key] = val?.toString() ?? '';
          });
          return result;
        } else if (value is Map) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key.toString()] = val?.toString() ?? '';
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse List<NotificationModel>
      List<NotificationModel> parseNotifications(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          List<NotificationModel> result = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              result.add(NotificationModel.fromMap(item));
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result.add(NotificationModel.fromMap(Map<String, dynamic>.from(item)));
            } else {
              result.add(NotificationModel(
                title: '',
                message: '',
                timestamp: DateTime.now(),
              ));
            }
          }
          return result;
        }
        return [];
      }
      
      // Helper function untuk parse Map<String, EnrollmentData>
      Map<String, EnrollmentData> parseEnrollments(dynamic value) {
        if (value == null) return {};
        if (value is Map) {
          Map<String, EnrollmentData> result = {};
          value.forEach((key, item) {
            if (item is Map<String, dynamic>) {
              result[key.toString()] = EnrollmentData.fromMap(item);
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result[key.toString()] = EnrollmentData.fromMap(Map<String, dynamic>.from(item));
            } else {
              result[key.toString()] = EnrollmentData(
                date: DateTime.now(),
                lastAccessed: DateTime.now(),
              );
            }
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse Map<String, SubmissionData>
      Map<String, SubmissionData> parseSubmissions(dynamic value) {
        if (value == null) return {};
        if (value is Map) {
          Map<String, SubmissionData> result = {};
          value.forEach((key, item) {
            if (item is Map<String, dynamic>) {
              result[key.toString()] = SubmissionData.fromMap(item);
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result[key.toString()] = SubmissionData.fromMap(Map<String, dynamic>.from(item));
            } else {
              result[key.toString()] = SubmissionData(
                content: '',
                timestamp: DateTime.now(),
              );
            }
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse Map<String, List<QuizAttempt>>
      Map<String, List<QuizAttempt>> parseQuizAttempts(dynamic value) {
        if (value == null) return {};
        if (value is Map) {
          Map<String, List<QuizAttempt>> result = {};
          value.forEach((key, items) {
            if (items is List) {
              List<QuizAttempt> attempts = [];
              for (var item in items) {
                if (item is Map<String, dynamic>) {
                  attempts.add(QuizAttempt.fromMap(item));
                } else if (item is Map) {
                  // Explicit cast untuk mengatasi masalah tipe data
                  attempts.add(QuizAttempt.fromMap(Map<String, dynamic>.from(item)));
                } else {
                  attempts.add(QuizAttempt(
                    timestamp: DateTime.now(),
                    answers: {},
                    score: 0,
                  ));
                }
              }
              result[key.toString()] = attempts;
            } else {
              result[key.toString()] = [];
            }
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse Map<String, GradeData>
      Map<String, GradeData> parseGrades(dynamic value) {
        if (value == null) return {};
        if (value is Map) {
          Map<String, GradeData> result = {};
          value.forEach((key, item) {
            if (item is Map<String, dynamic>) {
              result[key.toString()] = GradeData.fromMap(item);
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result[key.toString()] = GradeData.fromMap(Map<String, dynamic>.from(item));
            } else {
              result[key.toString()] = GradeData();
            }
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse List<String>
      List<String> parseStringList(dynamic value) {
        if (value == null) return [];
        if (value is List<String>) {
          return value;
        } else if (value is List) {
          return value.map((item) => item?.toString() ?? '').toList();
        }
        return [];
      }
      
      // Helper function untuk parse Map<String, int>
      Map<String, int> parseProgressMap(dynamic value) {
        if (value == null) return {};
        if (value is Map<String, int>) {
          return value;
        } else if (value is Map) {
          Map<String, int> result = {};
          value.forEach((key, val) {
            // Convert to int safely
            if (val is int) {
              result[key.toString()] = val;
            } else if (val is num) {
              result[key.toString()] = val.toInt();
            } else if (val is String) {
              result[key.toString()] = int.tryParse(val) ?? 0;
            } else {
              result[key.toString()] = 0;
            }
          });
          return result;
        }
        return {};
      }
      
      return StudentModel(
        id: map['id'] ?? '',
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        joinedDate: map['joinedDate'] != null 
            ? parseDateTime(map['joinedDate']) 
            : DateTime.now(),
        lastLogin: map['lastLogin'] != null 
            ? parseDateTime(map['lastLogin'])
            : null,
        isActive: map['isActive'] ?? true,
        profileData: parseProfileData(map['profileData']),
        notifications: parseNotifications(map['notifications']),
        enrolledCourses: parseEnrollments(map['enrolledCourses']),
        assignments: parseSubmissions(map['assignments']),
        quizAttempts: parseQuizAttempts(map['quizAttempts']),
        grades: parseGrades(map['grades']),
        certificates: parseStringList(map['certificates']),
        studyProgress: parseProgressMap(map['studyProgress']),
      );
    } catch (e) {
      log("Terjadi error pada StudentModel.fromMap: $e");
      // Fallback dengan minimal data
      return StudentModel(
        id: map['id'] ?? '',
        username: map['username'] ?? 'Unknown Student',
        email: map['email'] ?? '',
        joinedDate: DateTime.now(),
      );
    }
  }
}

class EducatorModel extends UserModel {
  final String specialization;
  final List<String> courses;
  final int teachingHours;
  final List<InstructorRating> ratings;

  EducatorModel({
    required super.id,
    required super.username,
    required super.email,
    required super.joinedDate,
    super.lastLogin,
    super.isActive,
    super.profileData,
    super.notifications,
    this.specialization = '',
    this.courses = const [],
    this.teachingHours = 0,
    this.ratings = const [],
  });

  @override
  String get userType => 'educator';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'joinedDate': joinedDate,
      'lastLogin': lastLogin,
      'isActive': isActive,
      'profileData': profileData,
      'notifications': notifications.map((e) => e.toMap()).toList(),
      'userType': userType,
      'specialization': specialization,
      'courses': courses,
      'teachingHours': teachingHours,
      'ratings': ratings.map((e) => e.toMap()).toList(),
    };
  }

  factory EducatorModel.fromMap(Map<String, dynamic> map) {
    try {
      log("EducatorModel.fromMap parsing data");
      
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      // Helper function untuk parse Map<String, String>
      Map<String, String> parseProfileData(dynamic value) {
        if (value == null) return {};
        if (value is Map<String, String>) {
          return value;
        } else if (value is Map<String, dynamic>) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key] = val?.toString() ?? '';
          });
          return result;
        } else if (value is Map) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key.toString()] = val?.toString() ?? '';
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse List<NotificationModel>
      List<NotificationModel> parseNotifications(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          List<NotificationModel> result = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              result.add(NotificationModel.fromMap(item));
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result.add(NotificationModel.fromMap(Map<String, dynamic>.from(item)));
            } else {
              result.add(NotificationModel(
                title: '',
                message: '',
                timestamp: DateTime.now(),
              ));
            }
          }
          return result;
        }
        return [];
      }
      
      // Helper function untuk parse List<String>
      List<String> parseStringList(dynamic value) {
        if (value == null) return [];
        if (value is List<String>) {
          return value;
        } else if (value is List) {
          return value.map((item) => item?.toString() ?? '').toList();
        }
        return [];
      }
      
      // Helper function untuk parse List<InstructorRating>
      List<InstructorRating> parseRatings(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          List<InstructorRating> result = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              result.add(InstructorRating.fromMap(item));
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result.add(InstructorRating.fromMap(Map<String, dynamic>.from(item)));
            } else {
              result.add(InstructorRating(
                studentId: '',
                rating: 0,
                timestamp: DateTime.now(),
              ));
            }
          }
          return result;
        }
        return [];
      }
      
      return EducatorModel(
        id: map['id'] ?? '',
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        joinedDate: map['joinedDate'] != null 
            ? parseDateTime(map['joinedDate']) 
            : DateTime.now(),
        lastLogin: map['lastLogin'] != null 
            ? parseDateTime(map['lastLogin'])
            : null,
        isActive: map['isActive'] ?? true,
        profileData: parseProfileData(map['profileData']),
        notifications: parseNotifications(map['notifications']),
        specialization: map['specialization'] ?? '',
        courses: parseStringList(map['courses']),
        teachingHours: map['teachingHours'] ?? 0,
        ratings: parseRatings(map['ratings']),
      );
    } catch (e) {
      log("Terjadi error pada EducatorModel.fromMap: $e");
      // Fallback dengan minimal data
      return EducatorModel(
        id: map['id'] ?? '',
        username: map['username'] ?? 'Unknown Educator',
        email: map['email'] ?? '',
        joinedDate: DateTime.now(),
        specialization: map['specialization'] ?? '',
      );
    }
  }
}

class EnrollmentData {
  final DateTime date;
  final String status;
  final int progress;
  final DateTime lastAccessed;

  EnrollmentData({
    required this.date,
    this.status = 'active',
    this.progress = 0,
    required this.lastAccessed,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'status': status,
      'progress': progress,
      'lastAccessed': lastAccessed,
    };
  }

  factory EnrollmentData.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      return EnrollmentData(
        date: map['date'] != null 
            ? parseDateTime(map['date'])
            : DateTime.now(),
        status: map['status'] ?? 'active',
        progress: map['progress'] is int 
            ? map['progress'] 
            : (map['progress'] is num 
                ? map['progress'].toInt() 
                : 0),
        lastAccessed: map['lastAccessed'] != null 
            ? parseDateTime(map['lastAccessed'])
            : DateTime.now(),
      );
    } catch (e) {
      log("Error parsing EnrollmentData: $e");
      return EnrollmentData(
        date: DateTime.now(),
        lastAccessed: DateTime.now(),
      );
    }
  }
}

class SubmissionData {
  final String content;
  final DateTime timestamp;
  final String status;
  final double? grade;
  final String? feedback;

  SubmissionData({
    required this.content,
    required this.timestamp,
    this.status = 'submitted',
    this.grade,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timestamp': timestamp,
      'status': status,
      'grade': grade,
      'feedback': feedback,
    };
  }

  factory SubmissionData.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      // Helper function untuk parse double
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }
      
      return SubmissionData(
        content: map['content'] ?? '',
        timestamp: map['timestamp'] != null 
            ? parseDateTime(map['timestamp'])
            : DateTime.now(),
        status: map['status'] ?? 'submitted',
        grade: parseDouble(map['grade']),
        feedback: map['feedback']?.toString(),
      );
    } catch (e) {
      log("Error parsing SubmissionData: $e");
      return SubmissionData(
        content: map['content'] ?? '',
        timestamp: DateTime.now(),
      );
    }
  }
}

class QuizAttempt {
  final DateTime timestamp;
  final Map<String, String> answers;
  final double score;
  final List<QuestionFeedback> feedback;

  QuizAttempt({
    required this.timestamp,
    required this.answers,
    required this.score,
    this.feedback = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'answers': answers,
      'score': score,
      'feedback': feedback.map((e) => e.toMap()).toList(),
    };
  }

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      // Helper untuk parse Map<String, String>
      Map<String, String> parseAnswers(dynamic value) {
        if (value == null) return {};
        if (value is Map<String, String>) {
          return value;
        } else if (value is Map) {
          Map<String, String> result = {};
          value.forEach((key, val) {
            result[key.toString()] = val?.toString() ?? '';
          });
          return result;
        }
        return {};
      }
      
      // Helper untuk parse List<QuestionFeedback>
      List<QuestionFeedback> parseFeedback(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          List<QuestionFeedback> result = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              result.add(QuestionFeedback.fromMap(item));
            } else if (item is Map) {
              // Explicit cast untuk mengatasi masalah tipe data
              result.add(QuestionFeedback.fromMap(Map<String, dynamic>.from(item)));
            } else {
              result.add(QuestionFeedback(
                questionId: '',
                questionText: '',
                isCorrect: false,
              ));
            }
          }
          return result;
        }
        return [];
      }
      
      // Helper function untuk parse double
      double parseScore(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }
      
      return QuizAttempt(
        timestamp: map['timestamp'] != null 
            ? parseDateTime(map['timestamp'])
            : DateTime.now(),
        answers: parseAnswers(map['answers']),
        score: parseScore(map['score']),
        feedback: parseFeedback(map['feedback']),
      );
    } catch (e) {
      log("Error parsing QuizAttempt: $e");
      return QuizAttempt(
        timestamp: DateTime.now(),
        answers: {},
        score: 0,
      );
    }
  }
}

class QuestionFeedback {
  final String questionId;
  final String questionText;
  final bool isCorrect;
  final String explanation;

  QuestionFeedback({
    required this.questionId,
    required this.questionText,
    required this.isCorrect,
    this.explanation = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }

  factory QuestionFeedback.fromMap(Map<String, dynamic> map) {
    try {
      return QuestionFeedback(
        questionId: map['questionId'] ?? '',
        questionText: map['questionText'] ?? '',
        isCorrect: map['isCorrect'] ?? false,
        explanation: map['explanation'] ?? '',
      );
    } catch (e) {
      log("Error parsing QuestionFeedback: $e");
      return QuestionFeedback(
        questionId: map['questionId'] ?? '',
        questionText: map['questionText'] ?? '',
        isCorrect: false,
      );
    }
  }
}

class GradeData {
  final double finalGrade;
  final Map<String, double> assignments;
  final Map<String, double> quizzes;
  final double participation;
  final double extraCredit;

  GradeData({
    this.finalGrade = 0.0,
    this.assignments = const {},
    this.quizzes = const {},
    this.participation = 0.0,
    this.extraCredit = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'finalGrade': finalGrade,
      'assignments': assignments,
      'quizzes': quizzes,
      'participation': participation,
      'extraCredit': extraCredit,
    };
  }

  factory GradeData.fromMap(Map<String, dynamic> map) {
    try {
      // Helper untuk parse Map<String, double>
      Map<String, double> parseDoubleMap(dynamic value) {
        if (value == null) return {};
        if (value is Map<String, double>) {
          return value;
        } else if (value is Map) {
          Map<String, double> result = {};
          value.forEach((key, val) {
            if (val is double) {
              result[key.toString()] = val;
            } else if (val is int) {
              result[key.toString()] = val.toDouble();
            } else if (val is String) {
              result[key.toString()] = double.tryParse(val) ?? 0.0;
            } else {
              result[key.toString()] = 0.0;
            }
          });
          return result;
        }
        return {};
      }
      
      // Helper function untuk parse double
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }
      
      return GradeData(
        finalGrade: parseDouble(map['finalGrade']),
        assignments: parseDoubleMap(map['assignments']),
        quizzes: parseDoubleMap(map['quizzes']),
        participation: parseDouble(map['participation']),
        extraCredit: parseDouble(map['extraCredit']),
      );
    } catch (e) {
      log("Error parsing GradeData: $e");
      return GradeData();
    }
  }
}

class InstructorRating {
  final String studentId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  InstructorRating({
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

  factory InstructorRating.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function untuk parse DateTime/Timestamp
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
        return DateTime.now();
      }
      
      // Helper function untuk parse double
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }
      
      return InstructorRating(
        studentId: map['studentId'] ?? '',
        rating: parseDouble(map['rating']),
        comment: map['comment'] ?? '',
        timestamp: map['timestamp'] != null 
            ? parseDateTime(map['timestamp'])
            : DateTime.now(),
      );
    } catch (e) {
      log("Error parsing InstructorRating: $e");
      return InstructorRating(
        studentId: map['studentId'] ?? '',
        rating: 0.0,
        timestamp: DateTime.now(),
      );
    }
  }
}