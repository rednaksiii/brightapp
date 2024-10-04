import 'package:brightapp/pages/home/home_page_logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePageUI extends StatelessWidget {
  const HomePageUI({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Create an instance of the backend logic
    final HomePageLogic homePageLogic = HomePageLogic();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BrightFeed',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: () {
              // Direct Messages button functionality to be implemented later
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: homePageLogic.posts.length, // Accessing posts from backend logic
        itemBuilder: (context, index) {
          final post = homePageLogic.posts[index];
          return PostItem(
            username: post['username']!,
            profilePicture: post['profilePicture']!,
            imageUrl: post['imageUrl']!,
            caption: post['caption']!,
          );
        },
      ),
    );
  }
}

// Individual Post Item Widget
class PostItem extends StatelessWidget {
  final String username;
  final String profilePicture;
  final String imageUrl;
  final String caption;

  const PostItem({
    super.key,
    required this.username,
    required this.profilePicture,
    required this.imageUrl,
    required this.caption,
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
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePicture),
                ),
                const SizedBox(width: 10),
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.more_vert),
              ],
            ),
          ),
          // Post image
          Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
          // Post actions (like, comment, share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {},
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Post caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$username: $caption',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
