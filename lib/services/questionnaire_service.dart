import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'authentication_service.dart';

//handles all API calls related to the questionnaire feature
class QuestionnaireService {
  final AuthenticationService _authService = AuthenticationService();

  //asks the backend whether this user has already submitted the questionnaire
  //returns true if they have, false if they havent
  Future<bool> hasCompleted() async {
    try {
      //get the stored JWT so we can authenticate the request
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/questionnaire/status'),
        headers: {
          'Content-Type': 'application/json',
          //the backend middleware reads this header to verify who the user is
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //backend returns { "completed": true } or { "completed": false }
        return data['completed'] == true;
      }

      
      return true;

    } catch (e) {
      return true;
    }
  }

  // sends the five question scores to the backend
  // returns the total score as an int if successful, null if something went wrong
  Future<int?> submit(Map<String, int> scores) async {
    try {
      final token = await _authService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/questionnaire/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        
        body: jsonEncode(scores),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        return data['total_score'] as int;
      }

      return null;

    } catch (e) {
      return null;
    }
  }

  //fetches the user's saved questionnaire scores from the backend
  //returns a map like { 'q1_score': 3, 'q2_score': 2, ... } or null if it fails
  Future<Map<String, int>?> getResponses() async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/questionnaire/responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // the backend returns { "responses": { "q1_score": 3, ... } }
        // convert the dynamic map into a Map<String, int>
        final responses = data['responses'] as Map<String, dynamic>;
        return responses.map((key, value) => MapEntry(key, value as int));
      }

      return null;

    } catch (e) {
      return null;
    }
  }
}