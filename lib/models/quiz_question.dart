
class QuizQuestion {
  final String text;
  final List<String> answers;
  final String correctAnswer;

  const QuizQuestion(this.text, this.answers, this.correctAnswer);

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final List<String> options = List<String>.from(json['options'] as List);
    final String correctAns = json['correctAnswer'] as String;

    if (!options.contains(correctAns)) {
      throw FormatException(
        'Correct answer "$correctAns" not found in options: $options',
      );
    }

    List<String> orderedAnswers = [correctAns];
    for (String opt in options) {
      if (opt != correctAns) {
        orderedAnswers.add(opt);
      }
    }

    return QuizQuestion(json['question'] as String, orderedAnswers, correctAns);
  }

  List<String> get shuffledAnswers {
    final shuffledList = List.of(answers);
    shuffledList.shuffle();
    return shuffledList;
  }
}
