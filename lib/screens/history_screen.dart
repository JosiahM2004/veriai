import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

//shows the users quiz performance per category
//uses the existing /progress endpoint via fetchProgress()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final QuizService _quizService = QuizService();

  bool _isLoading = true;

  //list of progress rows, each has name, type, total_attempts, correct_answers
  List<Map<String, dynamic>> _progress = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _quizService.fetchProgress();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score History'),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    //empty state — user hasnt completed any quizzes yet
    if (_progress.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'You haven\'t completed any quizzes yet. Take a quiz to start building your history!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    //one card per category
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _progress.length,
      itemBuilder: (context, index) {
        final row = _progress[index];
        final name = row['name'] as String;
        final totalAttempts = row['total_attempts'] as int;
        final correctAnswers = row['correct_answers'] as int;

        //work out the accuracy percentage, guarding against divide by zero
        final accuracy = totalAttempts == 0
            ? 0
            : ((correctAnswers / totalAttempts) * 100).round();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //category name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              //correct out of total
              Text(
                '$correctAnswers correct out of $totalAttempts attempts',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              //accuracy percentage in app blue
              Text(
                'Accuracy: $accuracy%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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