import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImagePickerPage extends StatefulWidget {
  const ProfileImagePickerPage({super.key});

  @override
  State<ProfileImagePickerPage> createState() => _ProfileImagePickerPageState();
}

class _ProfileImagePickerPageState extends State<ProfileImagePickerPage> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Function to take a photo using the camera
  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  // Function to upload the image to Firebase Storage and update Firestore
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg'); // Store the image with user's UID

      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the user's profile image URL in Firebase Auth and Firestore
      await user.updatePhotoURL(downloadUrl);

      // Update Firestore with the new profile image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
      });

      // Show a success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile image.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _imageFile = null; // Clear the selected image after uploading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Image'),
      ),
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo),
                        label: const Text('Pick from Gallery'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _takePhotoWithCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take a Photo'),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 30,
                        child: FloatingActionButton(
                          onPressed: _uploadProfileImage,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.check, color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
