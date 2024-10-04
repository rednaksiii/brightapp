import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPageLogic {
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(BuildContext context, String email, String password) async {
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
