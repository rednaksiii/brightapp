import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageLogic {
  String userName = 'Default Username';
  String userBio = 'Default Bio';
  String? profileImageUrl;
  int followersCount = 0;
  int followingCount = 0;
  List<Map<String, dynamic>> userPosts = [];

  final String userId;

  ProfilePageLogic(this.userId) {
    fetchUserData();
    fetchUserPosts();
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await doc.get();

      if (snapshot.exists) {
        userName = snapshot.get('username') ?? 'Default Username';
        userBio = snapshot.get('bio') ?? 'Default Bio';
        profileImageUrl = snapshot.get('profileImageUrl');
        followersCount = snapshot.get('followers') ?? 0;
        followingCount = snapshot.get('following') ?? 0;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Fetch user posts from Firestore
  Future<void> fetchUserPosts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      userPosts = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching user posts: $e");
    }
  }

  // Listen for real-time updates to follower and following count
  void listenToFollowerFollowingUpdates() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        followersCount = snapshot.get('followers') ?? 0;
        followingCount = snapshot.get('following') ?? 0;
      }
    });
  }
}
