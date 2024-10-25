import 'package:flutter/material.dart';
import 'package:brightapp/pages/profile/profile_imagepicker.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_page_logic.dart';
import 'edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfilePageUI extends StatefulWidget {
  const ProfilePageUI({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageUI> {
  late ProfilePageLogic profileLogic;
  File? _profileImage; // Variable to hold the selected image
  String? _profileImageUrl; // Variable to hold the profile image URL from Firebase
  List<File> _postImages = []; // List to hold user posts
  List<bool> _isHovered = []; // List to manage hover state for delete buttons

  @override
  void initState() {
    super.initState();
    profileLogic = ProfilePageLogic();
    _loadProfileData(); // Load saved data when the page initializes
  }


  // Load username, bio, and profile picture from local storage
Future<void> _loadProfileData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    profileLogic.userName = prefs.getString('username') ?? 'Default Username';
    profileLogic.userBio = prefs.getString('bio') ?? 'Default Bio';

    // Load profile image URL from SharedPreferences instead of a file path
    String? profileImageUrl = prefs.getString('profileImageUrl'); 
    if (profileImageUrl != null) {
      _profileImageUrl = profileImageUrl; // Set the loaded image URL
    }

    // Load post images (your existing code)
    List<String>? postImagePaths = prefs.getStringList('postImages');
    if (postImagePaths != null) {
      _postImages = postImagePaths.map((path) => File(path)).toList(); // Set the loaded post images
      _isHovered = List<bool>.filled(_postImages.length, false); // Initialize hover state
    }
  });
}


  // Save username, bio, profile picture, and post images to local storage
  Future<void> _saveProfileData(String username, String bio, String? imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('bio', bio);
    if (imagePath != null) {
      await prefs.setString('profileImage', imagePath); // Save the image path
    }
    // Save post images
    List<String> postImagePaths = _postImages.map((file) => file.path).toList();
    await prefs.setStringList('postImages', postImagePaths); // Save post image paths
  }

  // Function to pick an image for posts
  Future<void> _pickPostImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _postImages.add(File(image.path)); // Add the selected image to post images
        _isHovered.add(false); // Initialize hover state for the new image
      });
      await _saveProfileData(profileLogic.userName, profileLogic.userBio, _profileImage?.path); // Save updated profile data
    }
  }

  // Function to delete a post image
  void _deletePostImage(int index) {
    setState(() {
      _postImages.removeAt(index); // Remove image from the list
      _isHovered.removeAt(index); // Remove hover state for the deleted image
    });
    _saveProfileData(profileLogic.userName, profileLogic.userBio, _profileImage?.path); // Save updated profile data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Display profile picture
          GestureDetector(
            onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileImagePickerPage(), // Navigate to ProfileImagePickerPage
              ),
            ).then((result) {
              if (result != null) {
                setState(() {
                  _profileImage = File(result); // Update profile image with the result from image picker
                });
                _saveProfileData(profileLogic.userName, profileLogic.userBio, result); // Save updated profile image
                }
              });
            },
            child: CircleAvatar(
              radius: 50, // Set the radius of the circle
              backgroundImage: _profileImage != null
                  ? NetworkImage(_profileImageUrl!) // Display profile image from Firebase
                  : const AssetImage('assets/images/profile_picture.png'), // Default image
            ),
          ),
          const SizedBox(height: 20),
          // Display username and bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileLogic.userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  profileLogic.userBio,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to Edit Profile Page and handle result
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        initialUsername: profileLogic.userName,
                        initialBio: profileLogic.userBio,
                      ),
                    ),
                  ).then((result) {
                    if (result != null) {
                      setState(() {
                        profileLogic.userName = result['username'];
                        profileLogic.userBio = result['bio'];
                      });
                      _saveProfileData(result['username'], result['bio'], _profileImage?.path); // Save updated profile data
                      print("Profile updated: ${profileLogic.userName}, ${profileLogic.userBio}");
                    }
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Add Post Images Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickPostImage,
                child: const Text('Add Post Image'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Display post images in a grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                childAspectRatio: 1.0, // Aspect ratio for each child
              ),
              itemCount: _postImages.length,
              itemBuilder: (context, index) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isHovered[index] = true; // Set hover state to true
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHovered[index] = false; // Set hover state to false
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity, // Ensure full width
                        height: double.infinity, // Ensure full height
                        child: ClipRect(
                          child: Image.file(
                            _postImages[index],
                            fit: BoxFit.cover, // Cover the entire area
                          ),
                        ),
                      ),
                      if (_isHovered[index]) // Show delete button only on hover
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePostImage(index), // Delete post image
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
