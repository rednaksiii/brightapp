import 'package:flutter/material.dart';
import 'package:brightapp/pages/home/home_page_logic.dart';
import 'package:brightapp/pages/user_profile/user_profile_page_ui.dart';

class HomePageUI extends StatelessWidget {
  const HomePageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final HomePageLogic homePageLogic = HomePageLogic();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: homePageLogic.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostItem(
              username: post['username'] ?? 'Anonymous',
              profilePicture: post['profilePicture'] ?? 'https://via.placeholder.com/150',
              imageUrl: post['imageUrl'],
              caption: post['caption'],
              userId: post['userId'],
            );
          },
        );
      },
    );
  }
}

// Individual Post Item Widget
class PostItem extends StatelessWidget {
  final String username;
  final String profilePicture;
  final String imageUrl;
  final String caption;
  final String userId;

  const PostItem({
    super.key,
    required this.username,
    required this.profilePicture,
    required this.imageUrl,
    required this.caption,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with profile picture and username
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePageUI(userId: userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profilePicture),
                  ),
                ),
                const SizedBox(width: 10),
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Post image
          Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
          // Post caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
