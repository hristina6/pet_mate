import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern color scheme
    final Color _primaryColor = const Color(0xFFFF9800);
    final Color _backgroundColor = Colors.white;
    final Color _cardColor = Colors.grey[50]!;
    final Color _textColor = Colors.grey[800]!;
    final Color _hintColor = Colors.grey[500]!;
    final Color _successColor = const Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Success Icon with Animation-like Design
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _successColor.withOpacity(0.9),
                      _successColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _successColor.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Success Title
              Text(
                'Welcome to PetMate!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Success Message
              Text(
                'Your account has been successfully created\nand you\'re now part of our pet-loving community!',
                style: TextStyle(
                  fontSize: 16,
                  color: _hintColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              // Celebration Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _successColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      size: 40,
                      color: _successColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to explore pets, connect with owners, and share your furry friends',
                      style: TextStyle(
                        fontSize: 14,
                        color: _hintColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to LoginScreen and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _primaryColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Sign In to Your Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Additional Info
              Text(
                'You can now log in with your email and password',
                style: TextStyle(
                  fontSize: 14,
                  color: _hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}