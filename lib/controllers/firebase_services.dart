import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

final _firestore = FirebaseFirestore.instance;

// Function to upload the image to Firebase Storage
Future<String?> uploadImageToFirebase(XFile imageFile) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
    final uploadTask = storageRef.putFile(File(imageFile.path));
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Image upload failed: $e');
    return null;
  }
}

// Function to create a Firestore document for the post
Future<void> createPost(String imageUrl, String caption, String userId, String username, String profilePicture) async {
  try {
    final postRef = await _firestore.collection('posts').add({
      'imageUrl': imageUrl,
      'caption': caption,
      'username': username,
      'profilePicture': profilePicture,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likes': [],
    });
    print('Post created with ID: ${postRef.id}');
  } catch (e) {
    print('Failed to create post: $e');
  }
}

// Function to fetch random posts
Future<List<Map<String, dynamic>>> fetchRandomPosts(int limit) async {
  List<Map<String, dynamic>> randomPosts = [];
  try {
    bool orderDescending = Random().nextBool();
    QuerySnapshot querySnapshot = await _firestore
        .collection('posts')
        .orderBy('timestamp', descending: orderDescending)
        .limit(limit)
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
      randomPosts.add(postData);
    }
  } catch (e) {
    print('Failed to fetch random posts: $e');
  }
  return randomPosts;
}

// Function to toggle a like and create a notification if liked
Future<void> toggleLike(String postId, String userId, bool isLiked, String postOwnerId) async {
  final postRef = _firestore.collection('posts').doc(postId);

  try {
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
      if (userId != postOwnerId) {
        await _firestore.collection('notifications').add({
          'userId': postOwnerId,
          'title': 'New Like',
          'message': 'User $userId liked your post.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
    print("Like status updated");
  } catch (e) {
    print('Failed to toggle like: $e');
  }
}

// Function to add a comment and create a notification for the post owner
Future<void> addComment(String postId, String userId, String comment, String postOwnerId) async {
  final postRef = _firestore.collection('posts').doc(postId);

  try {
    await postRef.collection('comments').add({
      'userId': userId,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (userId != postOwnerId) {
      await _firestore.collection('notifications').add({
        'userId': postOwnerId,
        'title': 'New Comment',
        'message': 'User $userId commented: $comment',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    print("Comment added successfully");
  } catch (e) {
    print('Failed to add comment: $e');
  }
}


