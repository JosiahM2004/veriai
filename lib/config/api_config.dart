//API configuration
//changing the server URL here updates it everywhere in the app
class ApiConfig {
  
  static const String baseUrl = 'http://129.12.153.135:3000';

  //authentication endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  //quiz endpoints
  static const String quizContent = '$baseUrl/quiz/content';
  static const String quizAttempt = '$baseUrl/quiz/attempt';
  static const String quizProgress = '$baseUrl/quiz/progress';
}