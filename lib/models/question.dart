enum ContentType { formal, informal, video }

class Question {
  final String id;
  final String contextInfo;
  final String content;
  final bool isAI;
  final String explanation;
  final ContentType type;

  const Question({
    required this.id,
    required this.contextInfo,
    required this.content,
    required this.isAI,
    required this.explanation,
    required this.type,
  });
}

class QuestionResult {
  final Question question;
  final bool userAnswer;
  final String userExplanation;

  bool get wasCorrect => userAnswer == question.isAI;

  QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.userExplanation,
  });
}