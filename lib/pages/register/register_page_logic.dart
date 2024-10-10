import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPageLogic {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the TextFields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Error message string
  String errorMessage = '';

  // Constructor to initialize context
  RegisterPageLogic(this.context);

  // Method to register a new user using Firebase
  Future<void> register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigate to the home page on successful registration
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'An error occurred';
    }
  }

  // Navigate to login page
  void navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Dispose controllers when no longer needed
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
