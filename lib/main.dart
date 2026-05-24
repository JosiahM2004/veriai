import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/authentication_service.dart';

//gives control to flutter 
void main() {
  runApp(const VeriAIApp());
}

//the root widget which contains the entire app
//super.key allows Flutter to track the widget internally
class VeriAIApp extends StatelessWidget {
  const VeriAIApp({super.key});

//creates the base visuals for the app, for example a light grey background for all pages 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeriAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C2C2C),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      ),
      home: const AuthenticationGate(),
    );
  }
}
//checks if a JWT token is stored on the device
//shows the home screen if logged in, login screen if not logged in
class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}
class _AuthenticationGateState extends State<AuthenticationGate> {
  final AuthenticationService _authenticationService = AuthenticationService();
  //tracks whether there is a finished checking for a stored token
  bool _isLoading = true;
  //stores the result of the token check
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    //chcek for a stored toekn as soon as the widget is created 
    _checkLoginStatus();
  }
  
  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authenticationService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    //show a loading spinner while checking for the token - prevents a flash of the wrong screen on startup
    if(_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF2C2C2C),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    //show the user the correct screen based on login status
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}