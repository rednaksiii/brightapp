import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageLogic {
  String _userName = 'Default Username';
  String _userBio = 'Default Bio';
  String? _profileImageUrl;

  // Getters for user details
  String get userName => _userName;
  String get userBio => _userBio;
  String? get profileImageUrl => _profileImageUrl;

  // Setters for user details (Add these to fix the issue)
  set userName(String value) {
    _userName = value;
  }

  set userBio(String value) {
    _userBio = value;
  }

  // Method to fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userUID = currentUser.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userUID).get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>?;

          _userName = data?['username'] ?? 'Anonymous';
          _userBio = data?['bio'] ?? 'No bio available';
          _profileImageUrl = data?['profileImageUrl'];
        } else {
          print("User document does not exist");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Method to update user data in Firestore
  Future<void> updateUserProfile(String newUserName, String newBio) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userUID = currentUser.uid;

      await FirebaseFirestore.instance.collection('users').doc(userUID).update({
        'username': newUserName,
        'bio': newBio,
      });

      _userName = newUserName;
      _userBio = newBio;
    }
  }
}
