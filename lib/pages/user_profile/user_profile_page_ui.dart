import 'package:flutter/material.dart';
import 'package:brightapp/pages/user_profile/user_profile_page_logic.dart';
import 'package:brightapp/pages/post_detail/post_detail_page.dart';

class UserProfilePageUI extends StatelessWidget {
  final String userId;

  const UserProfilePageUI({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProfileLogic = UserProfilePageLogic(userId: userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userProfileLogic.fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!;
          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: userData['profileImageUrl'] != null && userData['profileImageUrl'].isNotEmpty
                    ? NetworkImage(userData['profileImageUrl'])
                    : const NetworkImage('https://via.placeholder.com/150'),
              ),
              const SizedBox(height: 20),
              Text(
                userData['username'] ?? 'Anonymous',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                userData['bio'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: userProfileLogic.getUserPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No posts available"));
                    }

                    var posts = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post = posts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(postData: post),
                              ),
                            );
                          },
                          child: Image.network(
                            post['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
