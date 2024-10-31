import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostDetailPage({Key? key, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract fields from the postData map
    final String imageUrl = postData['imageUrl'];
    final String caption = postData['caption'];
    final Timestamp timestamp = postData['timestamp'];
    final String username = postData['username'];

    // Convert Firestore Timestamp to DateTime
    DateTime postDate = timestamp.toDate();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Allow users to tap on the image for a fullscreen effect
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenImagePage(imageUrl: imageUrl),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the caption
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display the username and timestamp
                    Row(
                      children: [
                        Text(
                          'Posted by: $username',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Posted on: ${postDate.toLocal()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Dismiss fullscreen on tap
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
