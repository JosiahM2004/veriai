import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}