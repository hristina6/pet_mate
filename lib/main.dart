import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/add_pet_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
