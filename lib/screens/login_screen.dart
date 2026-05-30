import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../services/questionnaire_service.dart';
import 'questionnaire_screen.dart';

//statefulwidget because the screen has changing data
//the text fields, loading state and error message all change as the user interacts
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //controllers allow user input to be read
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthenticationService _authenticationService = AuthenticationService();
  final QuestionnaireService _questionnaireService = QuestionnaireService();

  //tracks whether the login request is in progress so a loading spinner can be shown
  bool _isLoading = false;

  //stores any error message returned from the backend to show to the user
  String? _errorMessage;

  //called when the user taps the login button
  Future<void> _login() async {
    //clear any previous error message
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    //send the login request to the backend
    final error = await _authenticationService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

   //if error is null the login was successful
    if (error == null) {
      if (mounted) {
        //check if this user has already completed the questionnaire
        final completed = await _questionnaireService.hasCompleted();

        if (!mounted) return;

        if (completed) {
          //questionnaire complete? = yes - navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          //questionnaire complete? = no - navigate to QuestionnaireScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
            (route) => false,
          );
        }
      }
    } else {
      //show the error message from the backend
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  //free up the controllers when the screen is removed from the widget tree
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          //background image — same as home screen for consistency
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          //dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    
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

                    const Text(
                      'Truth matters in the age of AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 48),

                    //login form container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(height: 24),

                          //email field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          //password field — obscureText hides the characters
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          //error message — only shown if login fails
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          //login button — shows a spinner while the request is in progress
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A7BD5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          //link to register screen
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Don\'t have an account? Register here',
                              style: TextStyle(color: Color(0xFF3A7BD5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}