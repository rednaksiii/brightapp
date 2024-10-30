import 'package:flutter/material.dart';
import 'package:brightapp/pages/profile/profile_imagepicker.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_page_logic.dart';
import 'edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageUI extends StatefulWidget {
  const ProfilePageUI({Key? key}) : super(key: key);

  @override
  _ProfilePageUIState createState() => _ProfilePageUIState();
}

class _ProfilePageUIState extends State<ProfilePageUI> {
  late ProfilePageLogic profileLogic;
  File? _profileImage;
  String? _profileImageUrl;
  List<File> _postImages = [];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    profileLogic = ProfilePageLogic(userId);
    profileLogic.listenToFollowerFollowingUpdates();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileLogic.userName = prefs.getString('username') ?? 'Default Username';
      profileLogic.userBio = prefs.getString('bio') ?? 'Default Bio';
      String? profileImageUrl = prefs.getString('profileImageUrl');

       // Set _profileImageUrl from FirebaseAuth photoURL if available
      final userPhotoURL = FirebaseAuth.instance.currentUser?.photoURL;
      _profileImageUrl = userPhotoURL ?? profileImageUrl;

      List<String>? postImagePaths = prefs.getStringList('postImages');
      if (postImagePaths != null) {
        _postImages = postImagePaths.map((path) => File(path)).toList();
      }
    });
  }

  Future<void> _saveProfileData(String username, String bio, String? imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('bio', bio);
    if (imagePath != null) {
      await prefs.setString('profileImageUrl', imagePath);
    }
    List<String> postImagePaths = _postImages.map((file) => file.path).toList();
    await prefs.setStringList('postImages', postImagePaths);
  }

  Future<void> _pickPostImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _postImages.add(File(image.path));
      });
      await _saveProfileData(profileLogic.userName, profileLogic.userBio, _profileImage?.path);
    }
  }

  Future<void> _deletePostImage(int index) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _postImages.removeAt(index);
      });
      await _saveProfileData(profileLogic.userName, profileLogic.userBio, _profileImage?.path);
    }
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileImagePickerPage(),
                ),
              ).then((downloadUrl) {
                if (downloadUrl != null) {
                  setState(() {
                    _profileImageUrl = downloadUrl;
                  });
                  _saveProfileData(profileLogic.userName, profileLogic.userBio, downloadUrl);
                }
              });
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                ? (_profileImageUrl!.startsWith('http')
                  ? NetworkImage(_profileImageUrl!)
                  : FileImage(File(_profileImageUrl!)) as ImageProvider)
                : const AssetImage('assets/images/profile_picture.png'),
              onBackgroundImageError: (_, __) => const AssetImage('assets/images/profile_picture.png'), // Fallback if URL is invalid
            ),
          ),
          const SizedBox(height: 20),
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
          // Centralized Follower and Following Counts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '${profileLogic.followersCount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('Followers'),
                  ],
                ),
                const SizedBox(width: 40), // Space between the two counts
                Column(
                  children: [
                    Text(
                      '${profileLogic.followingCount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('Following'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                      _saveProfileData(result['username'], result['bio'], _profileImage?.path);
                    }
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: _postImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => _deletePostImage(index),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_postImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: GestureDetector(
                          onTap: () => _deletePostImage(index),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
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