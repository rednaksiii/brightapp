import 'package:flutter/material.dart';
import 'package:brightapp/pages/profile/profile_imagepicker.dart';
import 'profile_page_logic.dart';
import 'edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brightapp/pages/post_detail/post_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:brightapp/controllers/auth_controller.dart';


class ProfilePageUI extends StatefulWidget {
  const ProfilePageUI({Key? key}) : super(key: key);

  @override
  _ProfilePageUIState createState() => _ProfilePageUIState();
}

class _ProfilePageUIState extends State<ProfilePageUI> {
  late ProfilePageLogic profileLogic;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    profileLogic = ProfilePageLogic(userId);
    profileLogic.listenToFollowerFollowingUpdates();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    await profileLogic.fetchUserData();
    await profileLogic.fetchUserPosts();
    setState(() {}); // Refresh UI with fetched data
  }

  Future<void> _pickProfileImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileImagePickerPage()),
    );
    if (result != null) {
      setState(() {
        profileLogic.profileImageUrl = result;
      });
      await profileLogic.fetchUserData(); // Update Firestore with the new profile image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthController>(context, listen: false).signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profileLogic.profileImageUrl != null
                  ? NetworkImage(profileLogic.profileImageUrl!) as ImageProvider
                  : const AssetImage('assets/images/profile_picture.png'),
              onBackgroundImageError: (_, __) => const AssetImage(
                  'assets/images/profile_picture.png'), // Fallback if URL is invalid
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
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '${profileLogic.followersCount}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('Followers'),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    Text(
                      '${profileLogic.followingCount}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
                    }
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: profileLogic.userPosts.length,
              itemBuilder: (context, index) {
                final post = profileLogic.userPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(postData: post),
                      ),
                    );
                  },
                  child: Image.network(
                    post['imageUrl'],
                    fit: BoxFit.cover,
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
