import 'package:flutter/material.dart';
import 'dart:async';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer: 3 seconds ke baad login screen pe jayega
    Timer(const Duration(seconds: 3), () {
      // Navigator: ek screen se dusri screen pe jane ke liye
      // pushReplacement: current screen ko replace karta hai (back button se splash pe nahi aayega)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Light blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon (abhi ke liye icon use kar rahe hain)
            Icon(
              Icons.school,
              size: 100,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 20), // Space between icon and text
            
            // App Name
            const Text(
              'CSE Mentorship',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Connecting Mentors & Mentees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),
            
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
