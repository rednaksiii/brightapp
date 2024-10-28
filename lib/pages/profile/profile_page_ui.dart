import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'profile_page_logic.dart';
import 'edit_profile_page.dart';
import 'package:brightapp/pages/post_detail/post_detail_page.dart'; // Import PostDetailPage

class ProfilePageUI extends StatefulWidget {
  const ProfilePageUI({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageUI> {
  late ProfilePageLogic profileLogic;
  File? _profileImage;
  List<File> _postImages = [];
  List<bool> _isHovered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    profileLogic = ProfilePageLogic();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await profileLogic.fetchUserData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage, // Open the image picker on tap
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/profile_picture.png') as ImageProvider,
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
                          }
                        });
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Display post images in a grid
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid) // Get the current user's UID
                        .collection('posts') // Subcollection "posts" for this user
                        .orderBy('timestamp', descending: true) // Order posts by timestamp
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var posts = snapshot.data!.docs;

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post = posts[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the PostDetailPage when a post is clicked
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailPage(
                                    imageUrl: post['imageUrl'],
                                    caption: post['caption'],
                                    timestamp: post['timestamp'],
                                    username: profileLogic.userName,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              post['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Function to pick a profile image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }
}
