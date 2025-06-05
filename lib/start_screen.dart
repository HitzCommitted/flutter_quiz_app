import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen(this.startQuiz, {super.key});

  final void Function() startQuiz;

  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/quiz-logo.png',
            width: 350,
            color: Color.fromARGB(200, 250, 250, 250), // Subtle off-white
          ),
          SizedBox(height: 25),
          const Text(
            'Fast Questions! Smart Fun!',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: startQuiz,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.arrow_right_alt, size: 34),
            label: const Text('Start Quiz', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}
