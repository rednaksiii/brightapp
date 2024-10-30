import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// Function to upload the image to Firebase Storage
Future<String?> uploadImageToFirebase(XFile imageFile) async {
  try {
    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');

    // Upload the file
    final uploadTask = storageRef.putFile(File(imageFile.path));

    // Wait for the upload to complete
    final snapshot = await uploadTask.whenComplete(() => null);

    // Get the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return null;
  }
}

// Function to create a Firestore document for the post
Future<void> createPost(String imageUrl, String caption, String userId, String username, String profilePicture) async {
  try {
    // Add the post to the posts collection with the username and profile picture
    await FirebaseFirestore.instance.collection('posts').add({
      'imageUrl': imageUrl,
      'caption': caption,
      'username': username,
      'profilePicture': profilePicture,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the feed for each follower (if needed)
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List<String> followers = List<String>.from(userDoc['followers'] ?? []);
    for (String followerId in followers) {
      await FirebaseFirestore.instance.collection('feeds').doc(followerId).update({
        'posts': FieldValue.arrayUnion([userId]) // Update the user's feed with the new post
      });
    }
  } catch (e) {
    print('Failed to create post: $e');
  }
}

// Function to fetch a random post
Future<List<Map<String, dynamic>>> fetchRandomPosts(int limit) async {
  List<Map<String, dynamic>> randomPosts = [];
  try {
    // Randomly choose ascending or descending order
    bool orderDescending = Random().nextBool();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: orderDescending)
        .limit(limit)
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
      
      // Fetch user data (e.g., profile picture) from users collection
      if (postData['userId'] != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(postData['userId'])
            .get();

        if (userDoc.exists) {
          postData['profilePicture'] = userDoc['profileImageUrl'] ?? 'https://via.placeholder.com/150';
        } else {
          postData['profilePicture'] = 'https://via.placeholder.com/150';
        }
      }
      
      randomPosts.add(postData);
    }
  } catch (e) {
    print('Failed to fetch random posts: $e');
  }
  return randomPosts;
}


