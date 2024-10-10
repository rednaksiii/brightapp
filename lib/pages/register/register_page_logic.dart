import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controllers/auth_controller.dart';

class RegisterPageLogic {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the TextFields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  // // for confirm password
  // final RegisterPageLogic registerLogic = RegisterPageLogic(context);

  // Error message string
  String errorMessage = '';

  // Track if passwords match // for confirmpassword
  // bool passwordsMatch = true;

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
  }

  // // Method to check if passwords match // for confirm password
  // void checkPasswordsMatch() {
  //   passwordsMatch = passwordController.text == confirmPasswordController.text;
  // }
}
