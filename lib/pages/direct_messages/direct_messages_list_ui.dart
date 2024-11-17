import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page_ui.dart';

class DirectMessagesListUI extends StatelessWidget {
  const DirectMessagesListUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userId = user.id;

              // Skip current user in the list
              if (userId == currentUserId) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user['profileImageUrl'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                title: Text(user['username'] ?? 'Anonymous'),
                onTap: () async {
                  // Check if a conversation already exists between users
                  var conversationId = await _getOrCreateConversation(currentUserId, userId);

                  // Navigate to Chat Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPageUI(
                        conversationId: conversationId,
                        otherUserId: userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _getOrCreateConversation(String currentUserId, String otherUserId) async {
    // Query for an existing conversation
    var conversationsQuery = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in conversationsQuery.docs) {
      var participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id; // Return the existing conversation ID
      }
    }

    // Create a new conversation if it doesn't exist
    var newConversation = await FirebaseFirestore.instance.collection('conversations').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    return newConversation.id;
  }
}
