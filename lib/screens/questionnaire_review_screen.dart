import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';

//shows the user the questionnaire questions and the answer they gave for each
//no scores shown — just question + their chosen answer
class QuestionnaireReviewScreen extends StatefulWidget {
  const QuestionnaireReviewScreen({super.key});

  @override
  State<QuestionnaireReviewScreen> createState() => _QuestionnaireReviewScreenState();
}

class _QuestionnaireReviewScreenState extends State<QuestionnaireReviewScreen> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();

  //true while the answers are being fetched from the backend
  bool _isLoading = true;

  //the fetched scores, keyed by q1_score etc, null until loaded
  Map<String, int>? _responses;

  //the same question data as the questionnaire screen
  //each question has its text and the options with their score values
  //this lets us match a saved score back to the label the user picked
  final List<Map<String, dynamic>> _questions = [
    {
      'key': 'q1_score',
      'question': 'Do you think AI benefits businesses?',
      'options': [
        {'label': 'Yes', 'score': 3},
        {'label': 'Maybe', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'key': 'q2_score',
      'question': 'Are you aware of the environmental impact in the use of AI data centres?',
      'options': [
        {'label': 'Yes', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'key': 'q3_score',
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
      'key': 'q4_score',
      'question': 'Do you know the difference between misinformation and disinformation?',
      'options': [
        {'label': 'Yes', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
    {
      'key': 'q5_score',
      'question': 'AI has the potential to be used in journalism and in the news. Does this sound like a good thing to you?',
      'options': [
        {'label': 'Yes', 'score': 3},
        {'label': 'Maybe', 'score': 2},
        {'label': 'No', 'score': 1},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    //fetch the saved answers as soon as the screen opens
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final responses = await _questionnaireService.getResponses();
    if (!mounted) return;
    setState(() {
      _responses = responses;
      _isLoading = false;
    });
  }

  //takes a question and the saved score, returns the label that matches that score
  //for example score 3 on q1 returns "Yes"
  String _labelForScore(Map<String, dynamic> question, int score) {
    final options = question['options'] as List<Map<String, dynamic>>;
    for (final option in options) {
      if (option['score'] == score) {
        return option['label'] as String;
      }
    }
    //fallback if no match found, shouldnt normally happen
    return 'No answer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Questionnaire'),
        backgroundColor: const Color(0xFF3A7BD5),
        foregroundColor: Colors.white,
      ),
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
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    //show a spinner while loading
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    //handle the case where no answers came back
    if (_responses == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Could not load your questionnaire answers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    //build a card for each question showing the question and the chosen answer
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final key = question['key'] as String;
        //look up the saved score for this question
        final savedScore = _responses![key];
        //match the score back to the label
        final answerLabel = savedScore == null
            ? 'No answer'
            : _labelForScore(question, savedScore);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //the question text
              Text(
                question['question'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              //the user's answer, highlighted in the app blue
              Text(
                'Your answer: $answerLabel',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A7BD5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}