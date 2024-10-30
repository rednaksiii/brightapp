import 'package:flutter/material.dart';
import 'package:brightapp/controllers/firebase_services.dart';
import 'package:brightapp/pages/user_profile/user_profile_page_ui.dart';

class HomePageUI extends StatefulWidget {
  const HomePageUI({super.key});

  @override
  _HomePageUIState createState() => _HomePageUIState();
}

class _HomePageUIState extends State<HomePageUI> {
  List<Map<String, dynamic>> randomPosts = [];
  bool isLoading = false;

  // Fetch multiple random posts
  Future<void> fetchRandomPostsData() async {
    setState(() {
      isLoading = true;
    });

    randomPosts = await fetchRandomPosts(6); // Fetch 5-6 posts

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRandomPostsData(); // Fetch posts on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : randomPosts.isNotEmpty
                ? ListView.builder(
                    itemCount: randomPosts.length,
                    itemBuilder: (context, index) {
                      final post = randomPosts[index];
                      return PostItem(
                        username: post['username'] ?? 'Anonymous',
                        profilePicture: post['profilePicture'] ??
                            'https://via.placeholder.com/150',
                        imageUrl: post['imageUrl'] ??
                            'https://via.placeholder.com/300', // Handle null imageUrl
                        caption: post['caption'] ?? '',
                        userId: post['userId'] ?? 'unknown',
                      );
                    },
                  )
                : const Center(child: Text("No posts available")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchRandomPostsData, // Refreshes the feed
        child: const Icon(Icons.refresh),
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
                Text(username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
