import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  User? user;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      this.user = user;
      notifyListeners();
    });
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    user = _auth.currentUser;
    notifyListeners();
  }

  // Check if the user is logged in based on Firebase user
  bool isUserLoggedIn() {
    return user != null;
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign-in.';
    }
  }

  // Google login
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'unexpected error.';
    } catch (e) {
      throw 'Unexpected error occurred while signing you in.';
    }
  }

  // Facebook login
  Future<void> signInWithFacebook() async {
    print('signInWithFacebook method called');
    final LoginResult result = await _facebookAuth.login();

    print('Facebook login status: ${result.status}');
    print('Facebook login message: ${result.message}');

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      await _auth.signInWithCredential(credential);
    } else if (result.status == LoginStatus.cancelled) {
      throw Exception('Facebook login cancelled');
    } else {
      throw Exception(
          result.message ?? 'Unexpected error during Facebook login.');
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
      user = null;
      notifyListeners();
    } catch (e) {
      throw 'An error occurred while signing out.';
    }
  }
}
