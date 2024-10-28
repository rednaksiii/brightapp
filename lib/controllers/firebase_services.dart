import 'dart:io';
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
Future<void> createPost(String imageUrl, String caption, String username, String profilePicture, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('posts').add({
      'imageUrl': imageUrl,
      'caption': caption,
      'username': username,
      'profilePicture': profilePicture,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Failed to create post: $e');
  }
}

