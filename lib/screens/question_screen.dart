import 'package:flutter/material.dart';
import '../models/question.dart';
import 'feedback_screen.dart';
import 'result_screen.dart';
import '../services/quiz_service.dart';

//StatefulWidget means this screen has data that changes while it's running, because progress, score and text input are all tracked
//state class holds the data that changes internally while the screen is running
class QuestionScreen extends StatefulWidget { 
  final List<Question> questions;
  const QuestionScreen({super.key, required this.questions});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  
  int _currentIndex = 0;

  final List<QuestionResult> _results = [];

  final TextEditingController _explanationController = TextEditingController();
  final QuizService _quizService = QuizService();

  //when the quiz screen is removed from the app, Flutter will call dispose() automatically
  //TextEditingController must be disposed of manually to help free up memory 
  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  Question get _currentQuestion => widget.questions[_currentIndex];

  //called when the user taps the yes/no button
  Future<void> _submitAnswer(bool userAiAnswer) async {
    final explanation = _explanationController.text.trim();

    //creates a new QuestionResult and adds it to our results list - permanently records what happened on the question
    await _quizService.submitAttempt(
      contentId: _currentQuestion.id,
      userAnswer: userAiAnswer,
      userExplanation: explanation.isEmpty ? null: explanation,
    );
    _results.add(QuestionResult(
      question: _currentQuestion,
      userAnswer: userAiAnswer,
      userExplanation: explanation,
    ));

    //navigates to the feedback screen while passing 4 things:
    //result - the result just created 
    //questionNumber - the current question number shown in the header 
    //totalQuestions - total number of questions 
    //onNext - is a callback, a function passed in so that the feedback screen can call back when the user presses the Next button 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          result: _results.last,
          questionNumber: _currentIndex + 1,
          totalQuestions: widget.questions.length,
          onNext: _onFeedbackComplete,
        ),
      ),
    );
  }

  //the callback passed to the feedback screen - when the user taps next Navigator.pop() removes the feedback screen from the stack
  void _onFeedbackComplete() {
    Navigator.pop(context);

    final nextIndex = _currentIndex + 1;

    if (nextIndex >= widget.questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(results: _results),
        ),
      );
    } else {
      //setState() updates _currentIndex to the next question and clears the text field - without it the screen wouldn't update visually
      setState(() {
        _currentIndex = nextIndex;
        _explanationController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final questionNumber = _currentIndex + 1;
    final totalQuestions = widget.questions.length;

    return Scaffold(
      body: Stack(
        children: [

          //background image changes with each question
          //uses the current index to pick q1.jpg through q10.jpg
          Positioned.fill(
            child: Image.asset(
              'assets/images/q${_currentIndex + 1}.jpg',
              fit: BoxFit.cover,
            ),
          ),

          //semi-transparent dark overlay — makes content readable against any image
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),

          //SafeArea keeps content away from camera notches and system bars
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                //dark header bar showing question number and context
                Container(
                  color: const Color(0xFF2C2C2C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question $questionNumber of $totalQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.questionContext,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                //content box fills the top section and is scrollable for long passages
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        question.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                ),

                //yes/no buttons and explanation field pinned to the bottom
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      //yes / no buttons side by side
                      Row(
                        children: [
                          Expanded(
                            child: _AnswerButton(
                              label: 'Yes',
                              color: const Color(0xFF4CAF50),
                              onTap: () => _submitAnswer(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnswerButton(
                              label: 'No',
                              color: const Color(0xFFF44336),
                              onTap: () => _submitAnswer(false),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //optional explanation text field
                      TextField(
                        controller: _explanationController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Explain your answer here (optional)',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      //progress indicator
                      Text(
                        '$questionNumber of $totalQuestions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//private answer button widget — used for both Yes and No
//takes a label, colour and onTap callback
class _AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}