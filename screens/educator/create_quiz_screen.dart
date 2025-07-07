// lib/screens/educator/create_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:project_ilearn/models/module_model.dart';
import 'package:project_ilearn/models/quiz_model.dart';
import 'package:project_ilearn/providers/educator_provider.dart';
import 'package:project_ilearn/widgets/common/custom_button.dart';
import 'package:project_ilearn/widgets/common/custom_text_field.dart';
import 'package:project_ilearn/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class CreateQuizScreen extends StatefulWidget {
  final String courseId;
  final List<ModuleModel> modules;

  const CreateQuizScreen({
    super.key,
    required this.courseId,
    required this.modules,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ModuleModel _selectedModule;
  int _timeLimit = 30; // in minutes
  double _passingScore = 70.0;
  final List<QuestionModel> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedModule = widget.modules.first;
    // Add initial question
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _addQuestion() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _questions.add(
      QuestionModel(
        id: id,
        text: '',
        correctAnswer: '',
        questionType: 'multiple_choice',
        options: ['', '', '', ''],
      ),
    );
    setState(() {});
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz must have at least one question'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateQuestionText(int index, String text) {
    setState(() {
      _questions[index] = _questions[index].copyWith(text: text);
    });
  }

  void _updateQuestionType(int index, String type) {
    // If switching to true/false, adjust options
    final options = type == 'true_false'
        ? ['True', 'False']
        : _questions[index].options.length < 4
            ? [..._questions[index].options, '', '']
            : _questions[index].options;

    setState(() {
      _questions[index] = _questions[index].copyWith(
        questionType: type,
        options: options,
      );
    });
  }

  void _updateQuestionOptions(int index, int optionIndex, String value) {
    final updatedOptions = List<String>.from(_questions[index].options);
    updatedOptions[optionIndex] = value;

    setState(() {
      _questions[index] = _questions[index].copyWith(options: updatedOptions);
    });
  }

  void _updateCorrectAnswer(int index, String answer) {
    setState(() {
      _questions[index] = _questions[index].copyWith(correctAnswer: answer);
    });
  }

  void _updateExplanation(int index, String explanation) {
    setState(() {
      _questions[index] = _questions[index].copyWith(explanation: explanation);
    });
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1} text is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (question.correctAnswer.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1} correct answer is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (question.questionType == 'multiple_choice') {
        // Check if options are valid
        final emptyOptionIndex = question.options.indexWhere((option) => option.isEmpty);
        if (emptyOptionIndex != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Question ${i + 1} option ${emptyOptionIndex + 1} is required'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check if correct answer is one of the options
        if (!question.options.contains(question.correctAnswer)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Question ${i + 1} correct answer must be one of the options'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else if (question.questionType == 'true_false') {
        // Check if correct answer is either True or False
        if (question.correctAnswer != 'True' && question.correctAnswer != 'False') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Question ${i + 1} correct answer must be either True or False'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    final educatorProvider = Provider.of<EducatorProvider>(context, listen: false);

    final quiz = await educatorProvider.createQuiz(
      _selectedModule.id,
      _titleController.text,
      _descriptionController.text,
      _timeLimit,
      _passingScore,
      _questions,
    );

    if (quiz != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(educatorProvider.error ?? 'Failed to create quiz'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Basic Quiz Info
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Quiz Title',
                      validator:  _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Quiz Description',
                      maxLines: 3,
                      validator:  _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    
                    // Module Selection
                    DropdownButtonFormField<ModuleModel>(
                      value: _selectedModule,
                      decoration: const InputDecoration(
                        labelText: 'Module',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.modules.map((module) {
                        return DropdownMenuItem<ModuleModel>(
                          value: module,
                          child: Text(module.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedModule = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Time Limit
                    Row(
                      children: [
                        const Text('Time Limit (minutes):'),
                        Expanded(
                          child: Slider(
                            value: _timeLimit.toDouble(),
                            min: 5,
                            max: 180,
                            divisions: 35,
                            label: _timeLimit.toString(),
                            onChanged: (value) {
                              setState(() {
                                _timeLimit = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(_timeLimit.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Passing Score
                    Row(
                      children: [
                        const Text('Passing Score (%):'),
                        Expanded(
                          child: Slider(
                            value: _passingScore,
                            min: 50,
                            max: 100,
                            divisions: 10,
                            label: _passingScore.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _passingScore = value;
                              });
                            },
                          ),
                        ),
                        Text(_passingScore.toStringAsFixed(1)),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Questions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Questions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Questions List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Question ${index + 1}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _removeQuestion(index),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: question.text,
                                  decoration: const InputDecoration(
                                    labelText: 'Question Text',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                  onChanged: (value) => _updateQuestionText(index, value),
                                ),
                                const SizedBox(height: 16),
                                
                                // Question Type
                                DropdownButtonFormField<String>(
                                  value: question.questionType,
                                  decoration: const InputDecoration(
                                    labelText: 'Question Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'multiple_choice',
                                      child: Text('Multiple Choice'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'true_false',
                                      child: Text('True/False'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'short_answer',
                                      child: Text('Short Answer'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _updateQuestionType(index, value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Options (for Multiple Choice)
                                if (question.questionType == 'multiple_choice')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Options:'),
                                      const SizedBox(height: 8),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: question.options.length,
                                        itemBuilder: (context, optionIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: question.options[optionIndex],
                                                  groupValue: question.correctAnswer,
                                                  onChanged: (value) {
                                                    if (value != null && value.isNotEmpty) {
                                                      _updateCorrectAnswer(index, value);
                                                    }
                                                  },
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: question.options[optionIndex],
                                                    decoration: InputDecoration(
                                                      labelText: 'Option ${optionIndex + 1}',
                                                      border: const OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) =>
                                                        _updateQuestionOptions(index, optionIndex, value),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                
                                // True/False
                                if (question.questionType == 'true_false')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Correct Answer:'),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'True',
                                            groupValue: question.correctAnswer,
                                            onChanged: (value) {
                                              if (value != null) {
                                                _updateCorrectAnswer(index, value);
                                              }
                                            },
                                          ),
                                          const Text('True'),
                                          const SizedBox(width: 24),
                                          Radio<String>(
                                            value: 'False',
                                            groupValue: question.correctAnswer,
                                            onChanged: (value) {
                                              if (value != null) {
                                                _updateCorrectAnswer(index, value);
                                              }
                                            },
                                          ),
                                          const Text('False'),
                                        ],
                                      ),
                                    ],
                                  ),
                                
                                // Short Answer
                                if (question.questionType == 'short_answer')
                                  TextFormField(
                                    initialValue: question.correctAnswer,
                                    decoration: const InputDecoration(
                                      labelText: 'Correct Answer',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => _updateCorrectAnswer(index, value),
                                  ),
                                const SizedBox(height: 16),
                                
                                // Explanation
                                TextFormField(
                                  initialValue: question.explanation,
                                  decoration: const InputDecoration(
                                    labelText: 'Explanation (shown after answering)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                  onChanged: (value) => _updateExplanation(index, value),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    CustomButton(
                      onPressed: _createQuiz,
                      text: 'Create Quiz',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Tambahan untuk QuestionModel.copyWith
extension QuestionModelExtension on QuestionModel {
  QuestionModel copyWith({
    String? id,
    String? text,
    String? correctAnswer,
    int? points,
    String? questionType,
    List<String>? options,
    String? explanation,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      points: points ?? this.points,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
    );
  }
}