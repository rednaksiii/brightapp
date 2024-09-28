import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;

  // Track visibility of the welcome section
  bool showWelcomeMessage = true;

  @override
  Widget build(BuildContext context) {
    // Sample posts data
    final List<Map<String, String>> posts = [
      {
        'username': 'john_doe',
        'profilePicture': 'https://via.placeholder.com/150',
        'imageUrl': 'https://picsum.photos/400/300',
        'caption': 'Beautiful sunset in the mountains!',
      },
      {
        'username': 'jane_smith',
        'profilePicture': 'https://via.placeholder.com/150',
        'imageUrl': 'https://picsum.photos/400/300?2',
        'caption': 'Enjoying the beach life 🏖️',
      },
      {
        'username': 'user123',
        'profilePicture': 'https://via.placeholder.com/150',
        'imageUrl': 'https://picsum.photos/400/300?3',
        'caption': 'A nice cup of coffee to start the day ☕',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrightFeed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings (optional feature to be implemented)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Welcome Section if it's not hidden
            if (showWelcomeMessage) _buildWelcomeSection(),
            const SizedBox(height: 20),

            // Feed Section Title
            const Text(
              'Feed:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Feed List
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostItem(
                    username: post['username']!,
                    profilePicture: post['profilePicture']!,
                    imageUrl: post['imageUrl']!,
                    caption: post['caption']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Welcome Section Widget
  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Welcome Message
                Expanded(
                  child: Text(
                    'Welcome, ${user?.email}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // Close Button to hide the welcome message
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      showWelcomeMessage = false;
                    });
                  },
                ),
              ],
            ),
            Text('User ID: ${user?.uid}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
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
                Icon(Icons.favorite_border),
                const SizedBox(width: 15),
                Icon(Icons.chat_bubble_outline),
                const SizedBox(width: 15),
                Icon(Icons.send),
                const Spacer(),
                Icon(Icons.bookmark_border),
              ],
            ),
          ),
          // Post caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('$username: $caption'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
