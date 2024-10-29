import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePageLogic {
  final String userId;

  UserProfilePageLogic({required this.userId});

  // Function to fetch user data
  Future<Map<String, dynamic>> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  // Stream to get user's posts from the main 'posts' collection filtered by userId
  Stream<List<Map<String, dynamic>>> getUserPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userUID', isEqualTo: userId)  // Filter posts by userId
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return doc.data() as Map<String, dynamic>;
            }).toList());
  }
}
