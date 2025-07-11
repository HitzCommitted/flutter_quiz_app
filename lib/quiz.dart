import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/questions_screen.dart';
import 'package:flutter_quiz_app/start_screen.dart';
import 'package:flutter_quiz_app/results_screen.dart';
import 'package:flutter_quiz_app/models/quiz_question.dart';
import 'package:flutter_quiz_app/services/quiz_gemini_service.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  List<String> _selectedAnswers = [];
  var _activeScreen = 'start-screen';

  List<QuizQuestion> _loadedQuestions = [];
  bool _isLoadingQuestions = false;
  String? _questionsError;

  final QuizGeminiService _geminiService = QuizGeminiService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _questionsError = null;
      _loadedQuestions = [];
    });

    try {
      final questions = await _geminiService.generateQuizQuestions(
        'general knowledge',
        10,
      );
      setState(() {
        _loadedQuestions = questions;
      });
    } catch (e) {
      setState(() {
        _questionsError = 'Failed to load questions: ${e.toString()}';
        print('Error loading questions: $e');
      });
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  void _switchScreen() async {
    await _loadQuestions();

    if (_questionsError == null && _loadedQuestions.isNotEmpty) {
      setState(() {
        _activeScreen = 'questions-screen';
        _selectedAnswers = [];
      });
    } else {
      setState(() {
        _activeScreen = 'start-screen';
      });
    }
  }

  void _chooseAnswer(String answer) {
    _selectedAnswers.add(answer);

    if (_selectedAnswers.length == _loadedQuestions.length) {
      setState(() {
        _activeScreen = 'results-screen';
      });
    }
  }

  void restartQuiz() {
    setState(() {
      _selectedAnswers = [];
      _activeScreen = 'start-screen';
      _loadedQuestions = [];
      _questionsError = null;
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget = StartScreen(_switchScreen);

    if (_activeScreen == 'questions-screen') {
      if (_isLoadingQuestions) {
        screenWidget = const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      } else if (_questionsError != null) {
        screenWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Oops! $_questionsError\nPlease check your internet connection or API key.',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _switchScreen,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 107, 15, 168),
                ),
              ),
            ],
          ),
        );
      } else if (_loadedQuestions.isEmpty) {
        screenWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No questions were generated for the quiz. Please try again.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color.fromARGB(255, 230, 200, 253),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _switchScreen,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Quiz'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 107, 15, 168),
                ),
              ),
            ],
          ),
        );
      } else {
        screenWidget = QuestionsScreen(
          onSelectAnswer: _chooseAnswer,
          questions: _loadedQuestions,
        );
      }
    }

    if (_activeScreen == 'results-screen') {
      screenWidget = ResultsScreen(
        chosenAnswers: _selectedAnswers,
        onRestart: restartQuiz,
        questions: _loadedQuestions,
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 78, 13, 151),
                Color.fromARGB(255, 107, 15, 168),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
