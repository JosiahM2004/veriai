import 'package:flutter/material.dart';
import '../models/question.dart';
import 'home_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../services/quiz_service.dart';

//statefulwidget because the progress data is fetched from the backend after the screen loads
class ResultScreen extends StatefulWidget {
  final List<QuestionResult> results;

  const ResultScreen({super.key, required this.results});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final QuizService _quizService = QuizService();

  //stores the progress fetched from the backend
  List<Map<String, dynamic>> _progress = [];

  //tracks whether the progress is still loading
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    //fetch progress as soon as the result screen appears
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _quizService.fetchProgress();
    setState(() {
      _progress = progress;
      _loadingProgress = false;
    });
  }

  //counts how many results were correct
  int get _score => widget.results.where((r) => r.wasCorrect).length;

  // builds the text shared via the native share sheet
  //includes a performance message based on score threshold
  String _buildExportText() {
    final int total = widget.results.length;
    final int score = _score;

    //determines the category name from the first question's type
    //used to personalise the share message
    final String category = widget.results.first.question.type == ContentType.formal
        ? 'formal'
        : 'informal';

    //performance message — threshold is 5/10
    //>5 prints an encouragement message, 5< prints a congratulation message
    final String performanceMessage = score < 5
        ? 'Better luck next time'
        : 'Well done';

    final buffer = StringBuffer();

    //opening line — personalised to category and score
    buffer.writeln('$performanceMessage You scored $score out of $total on the VeriAI $category content test.\n');

    //per question breakdown
    for (int i = 0; i < widget.results.length; i++) {
      final r = widget.results[i];
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
    final int total = widget.results.length;

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

            //overall progress from the database — shows cumulative accuracy per category
            //shows a loading spinner while the data is being fetched
            if (_loadingProgress)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_progress.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your overall progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    //shows one row per category with accuracy percentage
                    ..._progress.map((p) {
                      final accuracy = p['total_attempts'] > 0
                          ? ((p['correct_answers'] / p['total_attempts']) * 100).toStringAsFixed(0)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${p['name']}: ${p['correct_answers']}/${p['total_attempts']} correct ($accuracy%)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333333),
                          ),
                        ),
                      );
                    }),
                  ],
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
                  itemCount: widget.results.length,
                  //thin line between each row to create separation
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final r = widget.results[index];
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
                              'Question ${index + 1}: $label / $verdict',
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

                      //export button — triggers the native share sheet
                      //passes the results as plain text to any app the user picks
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
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