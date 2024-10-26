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

  // Getter for userName
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
}

