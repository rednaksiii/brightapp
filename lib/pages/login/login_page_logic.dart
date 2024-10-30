import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:brightapp/controllers/auth_controller.dart';

class LoginPageLogic extends ChangeNotifier {
  // ChangeNotifier
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(
      BuildContext context, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

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
      notifyListeners();
    }
  }

  Future<void> loginWithEmailOrUsername(
      BuildContext context, String emailOrUsername, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // try to login if it's email formatted
      final emailRegex =
          RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
      if (emailRegex.hasMatch(emailOrUsername)) {
        await login(context, emailOrUsername, password);
      } else {
        // if it's username, try to find corresponding email from firebase
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          errorMessage = 'No username found';
          notifyListeners();
          return;
        }

        // bring email correspoding to username
        final email = userQuery.docs.first['email'];

        // login with email and password
        await login(context, email, password);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Use the fb login provided by auth_controller.dart
      final authController =
          Provider.of<AuthController>(context, listen: false);
      await authController.signInWithFacebook();

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      errorMessage = e.toString();
      print('Facebook Login Error: $e');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

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
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      errorMessage = 'Please enter your email to reset password.';
      notifyListeners();
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
      notifyListeners();
    }
  }
}
