import 'package:flutter/material.dart';
import '../models/question.dart';

class FeedbackScreen extends StatelessWidget {
  final QuestionResult result;
  final int questionNumber;
  final int totalQuestions;
  final VoidCallback onNext;

  const FeedbackScreen({
    super.key,
    required this.result,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    //was the user correct?
    final bool correct = result.wasCorrect;

    //green if correct, red if wrong
    final Color answerColor =
        correct ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    //label shown in the result banner
    final String answerLabel = correct ? 'Correct!' : 'Incorrect';

    return Scaffold(
      body: Stack(
        children: [

          //background image for feedback screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/feedback.jpg',
              fit: BoxFit.cover,
            ),
          ),

          //semi-transparent dark overlay — makes content readable against the image
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          //SafeArea keeps content away from camera notches and system bars
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                //header
                Container(
                  color: const Color(0xFF2C2C2C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    'Question $questionNumber • ${result.question.questionContext}',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 13,
                    ),
                  ),
                ),

                //scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        //answer result banner
                        //green if correct, red if wrong
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: answerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                answerLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'This content was ${result.question.isAI ? "AI generated" : "human written"}.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        //explanation block
                        //why was this AI or human written
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Why?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                result.question.explanation,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        //user's explanation
                        //only shown if the user typed something
                        if (result.userExplanation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your reasoning',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result.userExplanation,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Color(0xFF333333),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        //next button — calls back to QuestionScreen to handle navigation
                        //ternary operator changes label to 'See Results' on the final question
                        ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A7BD5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            questionNumber == totalQuestions
                                ? 'See Results'
                                : 'Next',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
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