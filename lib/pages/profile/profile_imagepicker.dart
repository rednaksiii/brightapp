import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  // Function to upload the image to Firebase Storage and update the user's profile image
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in again.')),
        );
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg'); // Store the image with user's UID

      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the Firebase image URL in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', downloadUrl); // Save the image URL

      // Update the user's profile with the new image URL
      await user.updatePhotoURL(downloadUrl);

      // Pass the new image URL back to the profile page
      if (mounted) {
        Navigator.pop(context, downloadUrl); // Pass the image URL back to ProfilePageUI
      }

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile image.')),
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
                      // Display the selected image in full screen
                      Positioned.fill(
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Check button floating at the bottom-right corner
                      Positioned(
                        bottom: 30, // Adjust based on your preference
                        right: 30,  // Adjust based on your preference
                        child: FloatingActionButton(
                          onPressed: _uploadProfileImage,
                          backgroundColor: Colors.white, // White color button
                          child: const Icon(Icons.check, color: Colors.black), // Black icon
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), // Rounded shape
                            side: const BorderSide(color: Colors.white, width: 2), // White border
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
