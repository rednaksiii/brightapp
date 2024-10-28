import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPageLogic {
  final BuildContext context;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController usernameOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';

  LoginPageLogic(this.context);

  // Login method that checks whether the user input is email or username
  Future<void> login() async {
    String input = usernameOrEmailController.text.trim();
    String email = input;

    if (!input.contains('@')) {
      // If input is not an email, assume it's a username
      try {
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('username', isEqualTo: input.toLowerCase())
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          email = query.docs.first['email'];
        } else {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'Username not found');
        }
      } catch (e) {
        errorMessage = 'Failed to find username: $e';
        return;
      }
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'An error occurred';
    }
  }

  // Navigate to register page
  void navigateToRegister() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  // Dispose controllers
  void dispose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
  }
}
