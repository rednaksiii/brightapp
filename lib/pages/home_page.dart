import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;

  // Sample posts data (to be replaced with real backend data later)
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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adding the app_icon to the app bar
            Image.asset(
              'assets/images/app_icon.png', // Path to your app_icon file
              width: 40, // Set the width for the app_icon
              height: 40, // Set the height for the app_icon
            ),
            const SizedBox(width: 10),
            const Text(
              'BrightFeed',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true, // Center the title and app_icon in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: () {
              // Direct Messages button functionality to be implemented later
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? ListView.builder(
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
            )
          : Center(
              child: Text(
                _getPageTitle(_selectedIndex),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  // Function to get the title for the non-home pages
  String _getPageTitle(int index) {
    switch (index) {
      case 1:
        return 'Search Page';
      case 2:
        return 'Post Page';
      case 3:
        return 'Activity Page';
      case 4:
        return 'Profile Page';
      default:
        return 'Page';
    }
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
