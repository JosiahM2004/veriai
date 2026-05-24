import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/question.dart';
import 'authentication_service.dart';

//handles all quiz related API calls
class QuizService {
  final AuthenticationService _authenticationService = AuthenticationService();

  //builds the authorisation header using the stored JWT token
  //this is attached to every request that requires authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authenticationService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //fetches questions from the backend for the chosen category type
  //returns a list of question objects or an empty list if that fails
  Future<List<Question>> fetchQuestions(String categoryType) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${ApiConfig.quizContent}/$categoryType'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contentList = data['content'];

        //convert each JSON object from the API into a question model
        return contentList.map((item) => Question.fromJson(item)).toList();
      } else {
        return [];
      }

    } catch (e) {
      //catches network errors 
      return [];
    }
  }

  //saves a users answer to the backend
  //returns true if the answer was correct, false if not
  //returns null if the request failed
  Future<bool?> submitAttempt({
    required String contentId,
    required bool userAnswer,
    String? userExplanation,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse(ApiConfig.quizAttempt),
        headers: headers,
        body: jsonEncode({
          'content_id': contentId,
          'user_answer': userAnswer,
          'user_explanation': userExplanation,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['is_correct'];
      } else {
        return null;
      }

    } catch (e) {
      return null;
    }
  }

  //fetches the logged in users progress per category
  //returns a list of progress objects or an empty list if that fails
  Future<List<Map<String, dynamic>>> fetchProgress() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse(ApiConfig.quizProgress),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['progress']);
      } else {
        return [];
      }

    } catch (e) {
      return [];
    }
  }
}