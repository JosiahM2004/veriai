import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../models/question.dart';
import 'question_screen.dart';

//statelesswidget - screen has no data which changes over time, home screen remains idle and waits for user input
//super.key passes an identifier to Flutter's internal widget tracking system
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //method is called when the user gives an input
  //navigator.push() adds a new screen on top of the current visible screen acting like a card stack
  //MaterialPageRoute defines which screen to show to the user
  //questions are passed directly into QuestionScreen so the same quiz screen works for both categories
  void _startQuiz(BuildContext context, List<Question> questions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          //background nature image — covers the entire screen
          //Positioned.fill stretches the image to fill all available space
          Positioned.fill(
            child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
            ),
             
          ),

          //semi-transparent dark overlay — makes white text readable against any photo
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          //SafeArea keeps content away from camera notches and system bars at the top and bottom of the screen
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const SizedBox(height: 16),

                  //VeriAI title — white text so it reads against the background image
                  const Text(
                    'VeriAI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //subtitle — matches wireframe
                  const Text(
                    'Truth matters in the age of AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const Spacer(),

                  //instruction box — semi-transparent white so background shows through slightly
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Please choose the category you would like to test yourself on',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                  const Spacer(),

                  //two tall buttons side by side — matches wireframe layout
                  //Row places them horizontally, Expanded makes them equal width
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      //informal button — left side
                      Expanded(
                        child: _CategoryButton(
                          label: 'Informal content - containing things like internet videos, text messages and more',
                          onTap: () => _startQuiz(context, informalQuestions),
                        ),
                      ),

                      const SizedBox(width: 12),

                      //formal button — right side
                      Expanded(
                        child: _CategoryButton(
                          label: 'Formal content - containing things like emails, news segments and educational/ informative books',
                          onTap: () => _startQuiz(context, formalQuestions),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//private widget which can only be used within this file, extends StatelessWidget meaning it inherits all the behaviour but has no changing data
//takes a label and onTap
//uses GestureDetector instead of ElevatedButton so we can fully control shape and text position
class _CategoryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //GestureDetector detects taps on any widget
      onTap: onTap,
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A7BD5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}