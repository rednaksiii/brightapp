import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import this to use Timestamp

class PostDetailPage extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final Timestamp timestamp; // Use Firestore's Timestamp type
  final String username;

  const PostDetailPage({
    Key? key,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the Firestore Timestamp to a DateTime
    DateTime postDate = timestamp.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the full image
            Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
            const SizedBox(height: 10),
            // Display the caption
            Text(
              caption,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display the username and timestamp
            Row(
              children: [
                Text(
                  'Posted by: $username',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  'Posted on: ${postDate.toLocal()}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
