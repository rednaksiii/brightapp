import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageLogic {
  // Function to get the user's posts from Firebase Firestore
  Stream<List<Map<String, dynamic>>> getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true) // Order posts by timestamp (newest first)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {
        'userId': doc['userId'], // Include the userId
        'username': doc['username'] ?? 'Anonymous',
        'profilePicture': doc['profilePicture'] ?? 'https://via.placeholder.com/150',
        'imageUrl': doc['imageUrl'],
        'caption': doc['caption'],
      };
    }).toList());
  }
}
