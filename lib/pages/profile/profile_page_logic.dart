import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageLogic {
  String _userName = 'Default Username';
  String _userBio = 'Default Bio';
  int followersCount = 0;
  int followingCount = 0;

  final String userId;

  ProfilePageLogic(this.userId) {
    _fetchUserData();
  }

  // Getters for user details
  String get userName => _userName;
  set userName(String value) => _userName = value;

  // Getter for userBio
  String get userBio => _userBio;
  set userBio(String value) => _userBio = value;

  // Fetch data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await doc.get();

      if (snapshot.exists) {
        _userName = snapshot.get('username') ?? 'Default Username';
        _userBio = snapshot.get('bio') ?? 'Default Bio';
        followersCount = snapshot.get('followers') ?? 0;
        followingCount = snapshot.get('following') ?? 0;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Update follower/following count in Firestore
  Future<void> updateFollowerFollowingCount() async {
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(userId);
      await doc.update({
        'followers': followersCount,
        'following': followingCount,
      });
    } catch (e) {
      print("Error updating follower/following count: $e");
    }
  }

  // Function to listen to updates in follower and following count
  void listenToFollowerFollowingUpdates() {
    FirebaseFirestore.instance.collection('users').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        followersCount = snapshot.get('followers') ?? 0;
        followingCount = snapshot.get('following') ?? 0;
        // Notify listeners if needed (if using a state management solution like Provider)
      }
    });
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
