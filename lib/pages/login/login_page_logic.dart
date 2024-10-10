import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightapp/controllers/auth_controller.dart';

class LoginPageLogic {
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(
      BuildContext context, String email, String password) async {
    isLoading = true;
    errorMessage = null;

    try {
      // Attempt to sign in
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Print the returned UserCredential for debugging
      print('UserCredential: $userCredential');
      print('User: ${userCredential.user}'); // Print the user details

      // Navigate to the home page on success
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
      print('Unexpected error: $e'); // Print the exact error
    } finally {
      isLoading = false;
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    isLoading = true;
    errorMessage = null;

    try {
      // Use the fb login provided by auth_controller.dart
      final authController =
          Provider.of<AuthController>(context, listen: false);
      await authController.signInWithFacebook();

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      errorMessage = e.toString();
      print('Facebook Login Error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;
    errorMessage = null;

    try {
      // Use the google login provided by auth_controller.dart
      final authController =
          Provider.of<AuthController>(context, listen: false);
      await authController.signInWithGoogle();

      // return homepage when login succeed
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      errorMessage = e.toString();
      print('Google Login Error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      errorMessage = 'Please enter your email to reset password.';
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
    }
  }
}
