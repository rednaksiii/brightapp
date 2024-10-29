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
