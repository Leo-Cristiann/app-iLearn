class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://ilearn-api.example.com';
  static const String apiVersion = 'v1';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String themeKey = 'theme_mode';
  
  // Assets Paths
  static const String imagePath = 'assets/images/';
  static const String iconPath = 'assets/icons/';
  
  // Default Values
  static const int defaultQuizTimeLimit = 60; // minutes
  static const double defaultPassingScore = 70.0; // percentage
  static const int maxCourseStudents = 50;
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String permissionError = 'You do not have permission to perform this action.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String courseEnrollSuccess = 'Successfully enrolled in the course!';
  static const String assignmentSubmitSuccess = 'Assignment submitted successfully!';
  static const String quizSubmitSuccess = 'Quiz submitted successfully!';
  
  // Content Types
  static const String contentTypeVideo = 'video';
  static const String contentTypeText = 'text';
  static const String contentTypePdf = 'pdf';
  static const String contentTypeImage = 'image';
  
  // Status Types
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';
  static const String statusSubmitted = 'submitted';
  static const String statusGraded = 'graded';
  
  // Question Types
  static const String questionTypeMultipleChoice = 'multiple_choice';
  static const String questionTypeTrueFalse = 'true_false';
  static const String questionTypeShortAnswer = 'short_answer';
  
  // Course Class Types
  static const String courseTypeSynchronous = 'Synchronous';
  static const String courseTypeAsynchronous = 'Asynchronous';
  
  // User Types
  static const String userTypeStudent = 'student';
  static const String userTypeEducator = 'educator';
  
  // Media Types
  static const String contentTypeVideoMp4 = 'video/mp4';
  static const String contentTypeVideoWebm = 'video/webm';
  static const String contentTypeAudioMp3 = 'audio/mp3';
  static const String contentTypeAudioWav = 'audio/wav';
  static const String contentTypeImageJpeg = 'image/jpeg';
  static const String contentTypeImagePng = 'image/png';
  static const String contentTypeImageGif = 'image/gif';
  static const String contentTypeApplicationPdf = 'application/pdf';
}