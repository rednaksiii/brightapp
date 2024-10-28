import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controllers/auth_controller.dart';

class RegisterPageLogic {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the TextFields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Error message string
  String errorMessage = '';

  // Constructor to initialize context
  RegisterPageLogic(this.context);

  // Method to validate the username
  void validateUsername(String username) {
    if (username != username.toLowerCase()) {
      errorMessage = 'Username must be in lowercase.';
    } else {
      errorMessage = ''; // Clear the error message
    }
  }

  // Method to register a new user using Firebase
  Future<void> register() async {
    if (errorMessage.isNotEmpty) {
      // Show error if the username is not valid
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the user's UID and prepare to save additional data
      User? user = userCredential.user;
      String userUID = user!.uid;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userUID).set({
        'email': emailController.text.trim(),
        'username': usernameController.text.trim().toLowerCase(),  // Ensure username is saved in lowercase
        'profileImageUrl': '',  // Empty by default until the user uploads a picture
        'userUID': userUID,  // UID from Firebase Authentication
      });

      // Navigate to the home page after successful registration
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'An error occurred';
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    try {
      await authController.signInWithGoogle();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  // Facebook Sign-In
  Future<void> signInWithFacebook() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    try {
      await authController.signInWithFacebook();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      errorMessage = e.toString();
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
    usernameController.dispose();
  }
}
