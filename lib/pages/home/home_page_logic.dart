import 'package:flutter/material.dart';
import 'package:brightapp/controllers/firebase_services.dart';
import 'package:brightapp/pages/user_profile/user_profile_page_ui.dart';
import 'package:brightapp/pages/direct_messages/direct_messages_list_ui.dart';

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

    randomPosts = await fetchRandomPosts(6); // Fetch 6 random posts

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
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send), // DM Icon
            onPressed: () {
              // Navigate to DirectMessagesListUI
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DirectMessagesListUI(),
                ),
              );
            },
          ),
        ],
      ),
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
                            'https://via.placeholder.com/300',
                        caption: post['caption'] ?? '',
                        userId: post['userId'] ?? 'unknown',
                        postId: post['postId'] ?? 'unknown',
                      );
                    },
                  )
                : const Center(child: Text("No posts available")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchRandomPostsData, // Refresh feed
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final String username;
  final String profilePicture;
  final String imageUrl;
  final String caption;
  final String userId;
  final String postId;

  const PostItem({
    super.key,
    required this.username,
    required this.profilePicture,
    required this.imageUrl,
    required this.caption,
    required this.userId,
    required this.postId,
  });

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isLiked = false;
  TextEditingController commentController = TextEditingController();

  // Function to toggle like status
  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    await toggleLike(
      widget.postId,
      widget.userId,
      isLiked,
      widget.userId,
    );
  }

  // Function to handle comment submission
  Future<void> _addComment() async {
    if (commentController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment added: ${commentController.text}")),
      );

      commentController.clear();
    }
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a Comment"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Enter your comment"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addComment(); // Submit comment
              },
              child: const Text("Submit"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePageUI(userId: widget.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePicture),
                  ),
                ),
                const SizedBox(width: 10),
                Text(widget.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Image.network(widget.imageUrl,
              fit: BoxFit.cover, width: double.infinity),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(widget.caption, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null),
                  onPressed: _toggleLike, // Like toggling function
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: _showCommentDialog, // Comment dialog function
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
