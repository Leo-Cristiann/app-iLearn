import 'package:flutter/material.dart';
import 'package:project_ilearn/models/assignment_model.dart';
import 'package:project_ilearn/models/course_model.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/models/user_model.dart';
import 'package:project_ilearn/providers/auth_provider.dart';
import 'package:project_ilearn/providers/student_provider.dart';
import 'package:project_ilearn/screens/student/submit_assignment_screen.dart';
import 'package:project_ilearn/screens/student/take_quiz_screen.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/empty_state.dart';
import 'package:project_ilearn/widgets/common/error_message.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  
  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  CourseModel? _course;
  List<ModuleModel> _modules = [];
  bool _isEnrolled = false;
  bool _isEnrolling = false;
  
  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }
  
  Future<void> _loadCourseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.checkCurrentUser();
      await studentProvider.selectCourse(widget.courseId);
      
      if (studentProvider.error != null) {
        setState(() {
          _errorMessage = studentProvider.error;
          _isLoading = false;
        });
        return;
      }
      
      final course = studentProvider.selectedCourse;
      final modules = studentProvider.courseModules;
      
      if (course == null) {
        setState(() {
          _errorMessage = 'Course not found';
          _isLoading = false;
        });
        return;
      }
      
      // Check if the user is enrolled in this course
      bool isEnrolled = false;
      if (authProvider.user != null && authProvider.user is StudentModel) {
        final student = authProvider.user as StudentModel;
        isEnrolled = student.enrolledCourses.containsKey(course.id);
      }
      
      setState(() {
        _course = course;
        _modules = modules;
        _isEnrolled = isEnrolled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _enrollCourse() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    if (authProvider.user == null || authProvider.user is! StudentModel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in as a student to enroll'),
        ),
      );
      return;
    }

    if (_isEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already enrolled in this course'),
        ),
      );
      return;
    }
    
    setState(() {
      _isEnrolling = true;
    });
    
    try {
      final student = authProvider.user as StudentModel;
      final result = await studentProvider.enrollCourse(widget.courseId, student);
      
      if (result) {
        await authProvider.checkCurrentUser();
        // Refresh course details
        await _loadCourseDetails();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled in the course'),
              backgroundColor: Colors.green,
            ),
          );
          
          setState(() {
            _isEnrolled = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(studentProvider.error ?? 'Failed to enroll in the course'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
    
    setState(() {
      _isEnrolling = false;
    });
  }
  
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _showQuizResult(BuildContext context, QuizModel quiz, QuizAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Results: ${quiz.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${attempt.score.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Passing Score: ${quiz.passingScore}%'),
            const SizedBox(height: 16),
            Text(
              attempt.score >= quiz.passingScore
                  ? 'Congratulations! You passed the quiz.'
                  : 'You did not pass the quiz. You can try again.',
              style: TextStyle(
                color: attempt.score >= quiz.passingScore
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (attempt.score >= quiz.passingScore) 
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakeQuizScreen(
                      quiz: quiz,
                      studentId: (Provider.of<AuthProvider>(context, listen: false).user as StudentModel).id,
                      readOnly: true, // Tambahkan parameter ini di TakeQuizScreen
                    ),
                  ),
                );
              },
              child: const Text('Review'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakeQuizScreen(
                      quiz: quiz,
                      studentId: (Provider.of<AuthProvider>(context, listen: false).user as StudentModel).id,
                    ),
                  ),
                );
              },
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_course?.title ?? 'Course Details'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _isEnrolled && _course != null
          ? _buildNavigationBar()
          : null,
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    
    if (_errorMessage != null) {
      return ErrorMessage(
        message: _errorMessage!,
        onRetry: _loadCourseDetails,
      );
    }
    
    if (_course == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Course Not Found',
        message: 'The course you are looking for does not exist.',
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_course!.thumbnail.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _course!.thumbnail,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            _course!.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _course!.subject,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _course!.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (!_isEnrolled)
            CustomButton(
              text: 'Enroll Now',
              isLoading: _isEnrolling,
              onPressed: _enrollCourse,
            ),
          if (_isEnrolled) ...[
            Text(
              'Modules',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildModulesList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildModulesList() {
    if (_modules.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_outlined,
        title: 'No Modules',
        message: 'This course does not have any modules yet.',
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(module.title),
            subtitle: Text(module.description),
            children: [
              _buildModuleContents(module),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildModuleContents(ModuleModel module) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final studentId = (authProvider.user as StudentModel).id;
    
    // Filter assignments, quizzes for this module
    final moduleAssignments = studentProvider.assignments
        .where((assignment) => module.assignments.contains(assignment.id))
        .toList();
        
    final moduleQuizzes = studentProvider.quizzes
        .where((quiz) => module.quizzes.contains(quiz.id))
        .toList();
    
    // Check if there are no contents
    if (moduleAssignments.isEmpty && moduleQuizzes.isEmpty && module.contentItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No content available in this module yet.'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content items
          if (module.contentItems.isNotEmpty) ...[
            const Text(
              'Learning Materials:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...module.contentItems.map((contentId) => _buildContentItem(contentId)),
            const SizedBox(height: 16),
          ],
          
          // Assignments
          if (moduleAssignments.isNotEmpty) ...[
            const Text(
              'Assignments:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...moduleAssignments.map((assignment) => _buildAssignmentCard(assignment, studentId)),
            const SizedBox(height: 16),
          ],
          
          // Quizzes
          if (moduleQuizzes.isNotEmpty) ...[
            const Text(
              'Quizzes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...moduleQuizzes.map((quiz) => _buildQuizCard(quiz, studentId)),
          ],
        ],
      ),
    );
  }

  Widget _buildContentItem(String contentId) {
    // Placeholder for content items
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.article),
        title: const Text('Learning Material'),
        subtitle: Text('Content ID: $contentId'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to content viewer when implemented
        },
      ),
    );
  }

  Widget _buildAssignmentCard(AssignmentModel assignment, String studentId) {
    final submission = assignment.submissions[studentId];
    final isSubmitted = submission != null;
    final isGraded = isSubmitted && submission.status == 'graded';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isSubmitted 
              ? isGraded 
                  ? Icons.check_circle
                  : Icons.assignment_turned_in 
              : Icons.assignment,
          color: isSubmitted
              ? isGraded
                  ? Colors.green
                  : Colors.blue
              : null,
        ),
        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
          style: TextStyle(
            color: DateTime.now().isAfter(assignment.dueDate) && !isSubmitted
                ? Colors.red
                : null,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubmitAssignmentScreen(
                assignment: assignment,
                readOnly: isGraded,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz, String studentId) {
    final attempts = quiz.attempts[studentId] ?? [];
    final hasAttempts = attempts.isNotEmpty;
    final latestAttempt = hasAttempts ? attempts.last : null;
    final isPassed = latestAttempt != null && latestAttempt.score >= quiz.passingScore;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          hasAttempts
              ? isPassed
                  ? Icons.check_circle
                  : Icons.refresh
              : Icons.quiz,
          color: hasAttempts
              ? isPassed
                  ? Colors.green
                  : Colors.orange
              : null,
        ),
        title: Text(
          quiz.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${quiz.questions.length} questions · ${quiz.timeLimit} min'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (hasAttempts && isPassed) {
            // Jika quiz sudah dikerjakan dan lulus, tampilkan hasil quiz
            _showQuizResult(context, quiz, latestAttempt);
          } else {
            // Jika belum dikerjakan atau belum lulus, arahkan ke halaman take quiz
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TakeQuizScreen(
                  quiz: quiz,
                  studentId: studentId,
                ),
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Default to Course tab
      onTap: (index) {
        if (index == 1) {
          // Assignments
          Navigator.pushNamed(
            context, 
            '/student/assignments',
            arguments: widget.courseId,
          );
        } else if (index == 2) {
          // Quizzes
          Navigator.pushNamed(
            context, 
            '/student/quizzes',
            arguments: widget.courseId,
          );
        } else if (index == 3) {
          // Schedule
          Navigator.pushNamed(
            context, 
            '/student/schedule',
            arguments: widget.courseId,
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Course',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assignments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Schedule',
        ),
      ],
    );
  }
}