import 'dart:convert'; // Required for jsonDecode to parse JSON strings
import 'package:google_generative_ai/google_generative_ai.dart'; // The official Google Generative AI SDK for Dart/Flutter
import 'package:flutter_quiz_app/models/quiz_question.dart'; // Your custom QuizQuestion model
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To securely access your API key from the .env file

class QuizGeminiService {
  late final GenerativeModel _model;

  final String _apiKey;

  QuizGeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY']! {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<List<QuizQuestion>> generateQuizQuestions(
    String topic,
    int numberOfQuestions,
  ) async {
    final prompt = '''
Generate exactly $numberOfQuestions multiple-choice quiz questions about "$topic".
Each question must have exactly 4 options.
The first option in the "options" array for each question must always be the correct answer.
Format the output as a JSON array of objects.
Each object should have the following keys:
  - "question": (string) The question text.
  - "options": (array of strings) A list of 4 answer options. The first element MUST be the correct answer.
  - "correctAnswer": (string) The correct answer text. This must match the first element of the "options" array.

Example structure for 2 questions:
```json
[
  {
    "question": "What is the capital of France?",
    "options": ["Paris", "Berlin", "Madrid", "Rome"],
    "correctAnswer": "Paris"
  },
  {
    "question": "Which planet is known as the Red Planet?",
    "options": ["Mars", "Jupiter", "Venus", "Earth"],
    "correctAnswer": "Mars"
  }
]
''';

    try {
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception(
          'Failed to generate questions: Empty response from AI.',
        );
      }

      String jsonString =
          response.text!.trim(); // Remove leading/trailing whitespace
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(
          '```json'.length,
        ); // Remove the opening '```json'
        if (jsonString.endsWith('```')) {
          jsonString = jsonString.substring(
            0,
            jsonString.length - '```'.length,
          ); // Remove the closing '```'
        }
      }

      final List<dynamic> jsonQuestions = jsonDecode(jsonString);

      return jsonQuestions.map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      print(
        'Error generating questions from Gemini: $e',
      ); // Log the error to the console for debugging.
      rethrow;
    }
  }
}
