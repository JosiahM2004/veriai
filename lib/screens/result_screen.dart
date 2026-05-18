import 'package:flutter/material.dart';
import '../models/question.dart';
import 'home_screen.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final List<QuestionResult> results;

  const ResultScreen({super.key, required this.results});

  //counts how many results were correct 
  int get _score => results.where((r) => r.wasCorrect).length;

 // builds the text shared via the native share sheet
 //includes a performance message based on score threshold
String _buildExportText() {
  final int total = results.length;
  final int score = _score;
  
  //determines the category name from the first question's type
  //used to personalise the share message
  final String category = results.first.question.type == ContentType.formal
      ? 'formal'
      : 'informal';

  //performance message — threshold is 5/10
  //>5 prints an encouregment message, 5< prints a congratulation message 
  final String performanceMessage = score < 5
      ? 'Better luck next time'
      : 'Well done';

  final buffer = StringBuffer();

  //opening line — personalised to category and score
  buffer.writeln('$performanceMessage You scored $score out of $total on the VeriAI $category content test.\n');

  //per question breakdown
  for (int i = 0; i < results.length; i++) {
    final r = results[i];
    final label = r.question.isAI ? 'AI generated' : 'Human generated';
    final verdict = r.wasCorrect ? 'correct' : 'incorrect';
    buffer.writeln('${i + 1}. $label / $verdict');
  }

  //footer
  buffer.writeln('\nTested using VeriAI');

  return buffer.toString();
}

  @override
  Widget build(BuildContext context) {
    final int total = results.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        //removes the back arrow — quiz is done
        automaticallyImplyLeading: false,
        title: const Text('Results'),
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //score header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Text(
                'You scored $_score out of $total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),

            //per question result list
            //scrollable numbered list showing every question result
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.separated(
                  itemCount: results.length,
                  //thin line between each row to create separation
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    final label = r.question.isAI
                        ? 'AI generated'
                        : 'human written';
                    final verdict = r.wasCorrect ? 'correct' : 'incorrect';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          //question number
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                          //question result description
                          Expanded(
                            child: Text(
                              '(${r.question.id}) = $label / $verdict',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          //green dot if correct, red dot if wrong
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: r.wasCorrect
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFF44336),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            //bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      //retry button — goes back to home to pick a category
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            //clears the entire navigation stack back to home
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      //export button — shows results as plain text in a dialog
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                          // triggers the native share sheet
                          // passes the results as plain text to any app the user picks
                           Share.share(_buildExportText(), subject: 'My VeriAI Results');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Export',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  //home button — clears entire stack and returns to home
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Home',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}