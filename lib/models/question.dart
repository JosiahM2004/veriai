enum ContentType { formal, informal}

//the blueprint for each question featured in the app
//all fields are final as the curated dataset will not change when using the app 
class Question {
  final String id;
  final String questionContext;
  final String content;
  final bool isAI;
  final String explanation;
  final ContentType type;

  const Question({
    required this.id,
    required this.questionContext,
    required this.content,
    required this.isAI,
    required this.explanation,
    required this.type,
  });
}

//stores everything which can happen during the answering of a question 
//is created at runtime as the user progresses - it's not const because it will change 
class QuestionResult {
  final Question question;
  final bool userAnswer; //true = user believes the content is AI generated, false = user believes the content is human generated 
  final String userExplanation;

//compares the user's selection to the actual answer
  bool get wasCorrect => userAnswer == question.isAI;

  QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.userExplanation,
  });
}