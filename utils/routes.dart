import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/screens/auth/forgot_password_screen.dart';
import 'package:project_ilearn/screens/auth/login_screen.dart';
import 'package:project_ilearn/screens/auth/register_screen.dart';
import 'package:project_ilearn/screens/auth/user_type_screen.dart';
import 'package:project_ilearn/screens/common/edit_profile_screen.dart';
import 'package:project_ilearn/screens/common/notifications_screen.dart';
import 'package:project_ilearn/screens/common/profile_screen.dart';
import 'package:project_ilearn/screens/common/settings_screen.dart';
import 'package:project_ilearn/screens/educator/assignments_management_screen.dart';
import 'package:project_ilearn/screens/educator/course_detail_screen.dart' as educator;
import 'package:project_ilearn/screens/educator/courses_management_screen.dart';
import 'package:project_ilearn/screens/educator/create_assignment_screen.dart';
import 'package:project_ilearn/screens/educator/create_course_screen.dart';
import 'package:project_ilearn/screens/educator/create_quiz_screen.dart';
import 'package:project_ilearn/screens/educator/educator_home_screen.dart';
import 'package:project_ilearn/screens/educator/grade_assignments_screen.dart';
import 'package:project_ilearn/screens/educator/quizzes_management_screen.dart';
import 'package:project_ilearn/screens/educator/students_list_screen.dart';
import 'package:project_ilearn/screens/splash_screen.dart';
import 'package:project_ilearn/screens/student/available_courses_screen.dart';
import 'package:project_ilearn/screens/student/assignments_screen.dart';
import 'package:project_ilearn/screens/student/course_detail_screen.dart' as student;
import 'package:project_ilearn/screens/student/my_courses_screen.dart';
import 'package:project_ilearn/screens/student/quizzes_screen.dart';
import 'package:project_ilearn/screens/student/schedule_screen.dart';
import 'package:project_ilearn/screens/student/student_home_screen.dart';
import 'package:project_ilearn/screens/student/submit_assignment_screen.dart';
import 'package:project_ilearn/screens/student/take_quiz_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String userType = '/user-type';
  static const String forgotPassword = '/forgot-password';
  static const String studentHome = '/student/home';
  static const String educatorHome = '/educator/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String availableCourses = '/student/available-courses';
  static const String myCourses = '/student/my-courses';
  static const String studentCourseDetail = '/student/course-detail';
  static const String assignments = '/student/assignments';
  static const String quizzes = '/student/quizzes';
  static const String submitAssignment = '/student/submit-assignment';
  static const String takeQuiz = '/student/take-quiz';
  static const String schedule = '/student/schedule';
  static const String coursesManagement = '/educator/courses-management';
  static const String createCourse = '/educator/create-course';
  static const String educatorCourseDetail = '/educator/course-detail';
  static const String studentsList = '/educator/students-list';
  static const String assignmentsManagement = '/educator/assignments-management';
  static const String createAssignment = '/educator/create-assignment';
  static const String gradeAssignments = '/educator/grade-assignments';
  static const String quizzesManagement = '/educator/quizzes-management';
  static const String createQuiz = '/educator/create-quiz';
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
  final routeName = routeSettings.name;

  if (routeName == AppRoutes.splash) {
    return MaterialPageRoute(builder: (_) => const SplashScreen());
  } 
  else if (routeName == AppRoutes.login) {
    return MaterialPageRoute(builder: (_) => const LoginScreen());
  } 
  else if (routeName == AppRoutes.register) {
    String userType = 'student';
    if (routeSettings.arguments != null) {
      userType = routeSettings.arguments as String;
    }
    return MaterialPageRoute(builder: (_) => RegisterScreen(userType: userType));
  } 
  else if (routeName == AppRoutes.userType) {
    return MaterialPageRoute(builder: (_) => const UserTypeScreen());
  } 
  else if (routeName == AppRoutes.forgotPassword) {
    return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
  } 
  else if (routeName == AppRoutes.studentHome) {
    return MaterialPageRoute(builder: (_) => const StudentHomeScreen());
  } 
  else if (routeName == AppRoutes.educatorHome) {
    return MaterialPageRoute(builder: (_) => const EducatorHomeScreen());
  } 
  else if (routeName == AppRoutes.profile) {
    return MaterialPageRoute(builder: (_) => const ProfileScreen());
  } 
  else if (routeName == AppRoutes.editProfile) {
    return MaterialPageRoute(builder: (_) => const EditProfileScreen());
  } 
  else if (routeName == AppRoutes.notifications) {
    return MaterialPageRoute(builder: (_) => const NotificationsScreen());
  } 
  else if (routeName == AppRoutes.settings) {
    return MaterialPageRoute(builder: (_) => const SettingsScreen());
  } 
  else if (routeName == AppRoutes.availableCourses) {
    return MaterialPageRoute(builder: (_) => const AvailableCoursesScreen());
  } 
  else if (routeName == AppRoutes.myCourses) {
    return MaterialPageRoute(builder: (_) => const MyCoursesScreen());
  } 
  else if (routeName == AppRoutes.studentCourseDetail) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => student.CourseDetailScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.assignments) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => AssignmentsScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.quizzes) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => QuizzesScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.submitAssignment) {
    AssignmentModel assignment = routeSettings.arguments as AssignmentModel;
    return MaterialPageRoute(builder: (_) => SubmitAssignmentScreen(assignment: assignment));
  } 
  else if (routeName == AppRoutes.takeQuiz) {
    Map<String, dynamic> args = routeSettings.arguments as Map<String, dynamic>;
    QuizModel quiz = args['quiz'] as QuizModel;
    String studentId = args['studentId'] as String;
    return MaterialPageRoute(
      builder: (_) => TakeQuizScreen(
        quiz: quiz,
        studentId: studentId,
      ),
    );
  } 
  else if (routeName == AppRoutes.schedule) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => ScheduleScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.coursesManagement) {
    return MaterialPageRoute(builder: (_) => const CoursesManagementScreen());
  } 
  else if (routeName == AppRoutes.createCourse) {
    return MaterialPageRoute(builder: (_) => const CreateCourseScreen());
  } 
  else if (routeName == AppRoutes.educatorCourseDetail) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => educator.CourseDetailScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.studentsList) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => StudentsListScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.assignmentsManagement) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => AssignmentsManagementScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.createAssignment) {
    Map<String, dynamic> args = routeSettings.arguments as Map<String, dynamic>;
    String courseId = args['courseId'] as String;
    List<ModuleModel> modules = args['modules'] as List<ModuleModel>;
    return MaterialPageRoute(
      builder: (_) => CreateAssignmentScreen(
        courseId: courseId,
        modules: modules,
      ),
    );
  } 
  else if (routeName == AppRoutes.gradeAssignments) {
    AssignmentModel assignment = routeSettings.arguments as AssignmentModel;
    return MaterialPageRoute(builder: (_) => GradeAssignmentsScreen(assignment: assignment));
  } 
  else if (routeName == AppRoutes.quizzesManagement) {
    String courseId = routeSettings.arguments as String;
    return MaterialPageRoute(builder: (_) => QuizzesManagementScreen(courseId: courseId));
  } 
  else if (routeName == AppRoutes.createQuiz) {
    Map<String, dynamic> args = routeSettings.arguments as Map<String, dynamic>;
    String courseId = args['courseId'] as String;
    List<ModuleModel> modules = args['modules'] as List<ModuleModel>;
    return MaterialPageRoute(
      builder: (_) => CreateQuizScreen(
        courseId: courseId,
        modules: modules,
      ),
    );
  }
  // Default route (not found)
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(
        child: Text('No route defined for ${routeSettings.name}'),
      ),
    ),
  );
}
}