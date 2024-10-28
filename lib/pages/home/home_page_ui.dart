import 'package:flutter/material.dart';
import 'package:brightapp/pages/home/home_page_logic.dart';

class HomePageUI extends StatelessWidget {
  const HomePageUI({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
                imageUrl: post['imageUrl'],
                caption: post['caption'],
              );
            },
          );
        },
      ),
    );
  }
}

// Individual Post Item Widget
class PostItem extends StatelessWidget {
  final String username;
  final String imageUrl;
  final String caption;

  const PostItem({
    super.key,
    required this.username,
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
          // Post header with username
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder
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
