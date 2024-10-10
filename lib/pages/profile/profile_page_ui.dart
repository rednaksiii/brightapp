import 'package:brightapp/pages/profile/profile_page_logic.dart';
import 'package:flutter/material.dart';

class ProfilePageUI extends StatelessWidget {
  const ProfilePageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfilePageLogic profileLogic = ProfilePageLogic();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Optional: Open settings or profile options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      profileLogic.userProfileImage, // Use profile picture from logic
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Stats (Posts, Followers, Following)
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(profileLogic.postsCount.toString(), "Posts"),
                            _StatColumn(profileLogic.followersCount.toString(), "Followers"),
                            _StatColumn(profileLogic.followingCount.toString(), "Following"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Username
                        Text(
                          profileLogic.userName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // User Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                profileLogic.userEmail,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                    // Optional: Navigate to Edit Profile Page
                  },
                  child: const Text('Edit Profile'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            const Divider(),
            // Posts Grid View (Placeholder for now)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Your Posts will appear here...",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for showing statistics like "Posts", "Followers", and "Following"
class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
