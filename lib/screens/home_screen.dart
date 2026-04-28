import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../models/question.dart';
import 'question_screen.dart';

//statelesswidget - screen has no data which changes over time, home screen remains idle and waits for user input
//super.key passes an identifier to Flutter's internal widget tracking system
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

//method is called when the user gives an input
//navigator.push() addas a new screen on top of the current visible screen actiing like a card stack
//MaterialPageRoute defines which screen to show to the user 
//questions are passed directly into QuestionScren so the same quiz screen works for both categories 

  void _startQuiz(BuildContext context, List<Question> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(questions: questions),
      ),
    );
  }

// SafeArea keeps content away from camera notches and system bars at the top and bottom of the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'VeriAI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Choose the type of content you would like to test yourself on',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              _CategoryButton(
                label: 'AI generated formal text',
                onTap: () => _startQuiz(context, formalQuestions),
              ),

              const SizedBox(height: 12),

              _CategoryButton(
                label: 'AI generated informal text',
                onTap: () => _startQuiz(context, informalQuestions),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

//private widget which can only be used within this file, extends StatelessWidget meaning it inherits all the behaviour but has no changing data 
//takes a label and onTap
class _CategoryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3A7BD5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}