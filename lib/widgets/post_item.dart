import 'package:flutter/material.dart';
import 'package:brightapp/pages/activity/notification_service.dart'; // Import notification service
import 'package:brightapp/pages/user_profile/user_profile_page_ui.dart'; // User profile page

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

  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;  // Toggle the like status
    });

    addNotification("Your post had a like.");
  }

  Future<void> _addComment() async {
    if (commentController.text.isNotEmpty) {
      addNotification("Your post received a comment: ${commentController.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment added: ${commentController.text}")),
      );

      commentController.clear();  // Clear the comment text field
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
                Navigator.of(context).pop();  // Close the dialog
                _addComment();  // Submit the comment
              },
              child: const Text("Submit"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),  // Close the dialog without submitting
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
                        builder: (context) => UserProfilePageUI(userId: widget.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePicture),
                  ),
                ),
                const SizedBox(width: 10),
                Text(widget.username, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Image.network(widget.imageUrl, fit: BoxFit.cover, width: double.infinity),
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
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
                  onPressed: _toggleLike,  // Like button action
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: _showCommentDialog,  // Comment button action
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

