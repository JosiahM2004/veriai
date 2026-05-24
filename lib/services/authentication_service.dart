import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

//handles all authentication related API calls and token storage
class AuthenticationService {
  //creates a single instance of secure storage used throughout this class
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  //the key used to store and retrieve the JWT token
  static const String _tokenKey = 'authentication_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  //saves the token and user info securely on the device
  Future<void> _saveAuthenticationData(String token, String userId, String username) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _usernameKey, value: username);
  }

  //retrieves the stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  //retrieves the stored username
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  //checks if the user is currently logged in by detecting if a token exists
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  //clears all stored authentication data - used when logging out
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  //sends a register request to the backend
  //returns null if successful, or an error message string if it fails
  Future<String?> register(String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        //tells the backend JSON is being sent
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        //save the token and user info on the device
        await _saveAuthenticationData(
          data['token'],
          data['user']['id'],
          data['user']['username'],
        );
        return null;
      } else {
        //return the error message from the backend
        return data['error'] ?? 'Registration failed';
      }

    } catch (e) {
      //catches network errors 
      return 'Could not connect to server';
    }
  }

  //sends a login request to the backend
  //returns null if successful, or an error message string if it fails
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthenticationData(
          data['token'],
          data['user']['id'],
          data['user']['username'],
        );
        return null;
      } else {
        return data['error'] ?? 'Login failed';
      }

    } catch (e) {
      return 'Could not connect to server';
    }
  }
}