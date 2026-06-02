import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';
import 'home_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();

  bool _isLoading = false;

  // tracks which question the user is currently on (0 to 4)
  int _currentQuestion = 0;

  // one slot per question, null means not yet answered
  final List<int?> _selectedAnswers = List.filled(5, null);

  // your original microsoft forms questions, reordered as agreed (6, 8, 7, 10, 11)
  // scores are assigned so that more engaged/aware answers score higher
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Do you think AI benefits businesses?',
      'options': [
        {'label': 'Yes', 'score': 3},
        {'label': 'Maybe', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'question': 'Are you aware of the environmental impact in the use of AI data centres?',
      'options': [
        {'label': 'Yes', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'question': 'How often do you use AI?',
      'options': [
        {'label': 'Daily', 'score': 5},
        {'label': 'A couple times per week', 'score': 4},
        {'label': 'Once a week', 'score': 3},
        {'label': 'A few times a month', 'score': 2},
        {'label': 'Less than once a month', 'score': 1},
      ],
    },
    {
      'question': 'Do you know the difference between misinformation and disinformation?',
      'options': [
        {'label': 'Yes', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'question': 'AI has the potential to be used in journalism and in the news. Does this sound like a good thing to you?',
      'options': [
        {'label': 'Yes', 'score': 3},
        {'label': 'Maybe', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
  ];

  void _selectAnswer(int score) {
    setState(() {
      _selectedAnswers[_currentQuestion] = score;
    });
  }

  Future<void> _advance() async {
    if (_selectedAnswers[_currentQuestion] == null) return;

    // more questions to go — just advance the index
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
      return;
    }

    // all 5 answered — build the scores map and submit
    setState(() {
      _isLoading = true;
    });

    final scores = {
      'q1_score': _selectedAnswers[0]!,
      'q2_score': _selectedAnswers[1]!,
      'q3_score': _selectedAnswers[2]!,
      'q4_score': _selectedAnswers[3]!,
      'q5_score': _selectedAnswers[4]!,
    };

    final totalScore = await _questionnaireService.submit(scores);

    if (!mounted) return;

    if (totalScore != null) {
      _showResultDialog();
    } else {
      //submission failed — still let the user through 
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      //user must tap the button 
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thank you!'),
        content: const Text(
          'Your responses have been saved. Now it\'s time to put your instincts to the test - lets see if you can tell AI from the real thing.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Start the quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestion + 1) / _questions.length;
    final question = _questions[_currentQuestion];
    final options = question['options'] as List<Map<String, dynamic>>;

    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const Text(
                    'AI Awareness Check',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 16),

                  //progress bar — value goes from 0.2 to 1.0 as the user moves through
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3A7BD5)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //question card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question['question'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //answer buttons — ListView so it scrolls if needed on small screens
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final score = option['score'] as int;
                        final isSelected = _selectedAnswers[_currentQuestion] == score;

                        return GestureDetector(
                          onTap: () => _selectAnswer(score),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              //blue when selected, white when not
                              color: isSelected
                                  ? const Color(0xFF3A7BD5)
                                  : Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3A7BD5)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              option['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF333333),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  //next on questions 1-4, submit on question 5
                  ElevatedButton(
                    onPressed: (_selectedAnswers[_currentQuestion] == null || _isLoading)
                        ? null
                        : _advance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7BD5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentQuestion < _questions.length - 1 ? 'Next' : 'Submit',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}