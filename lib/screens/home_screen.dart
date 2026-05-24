import 'package:flutter/material.dart';
import '../models/question.dart';
import 'question_screen.dart';
import 'login_screen.dart';
import '../services/authentication_service.dart';
import '../services/quiz_service.dart';

//statefulwidget because the screen now fetches data from the backend
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final QuizService _quizService = QuizService();

  //fetches questions for the selected category from the backend
  //then navigates to the question screen
  Future<void> _startQuiz(BuildContext context, String categoryType) async {
    final questions = await _quizService.fetchQuestions(categoryType);

    if (questions.isEmpty) {
      //show an error if no questions came back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load questions. Please try again.')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(questions: questions),
        ),
      );
    }
  }

  //logs the user out and returns them to the login screen
  Future<void> _logout(BuildContext context) async {
    await _authenticationService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          //background nature image — covers the entire screen
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

          //SafeArea keeps content away from camera notches and system bars
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //logout button in the top right corner
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _logout(context),
                      tooltip: 'Logout',
                    ),
                  ),

                  const SizedBox(height: 16),

                  //VeriAI title
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

                  //subtitle
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

                  //instruction box
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

                  //two tall buttons side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      //informal button — left side
                      Expanded(
                        child: _CategoryButton(
                          label: 'Informal content - containing things like internet videos, text messages and more',
                          onTap: () => _startQuiz(context, 'informal'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      //formal button — right side
                      Expanded(
                        child: _CategoryButton(
                          label: 'Formal content - containing things like emails, news segments and educational/ informative books',
                          onTap: () => _startQuiz(context, 'formal'),
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

//private widget which can only be used within this file
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