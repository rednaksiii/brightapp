import 'package:flutter/material.dart';
import 'search_page_logic.dart';
import 'package:brightapp/pages/user_profile/user_profile_page_ui.dart';

class SearchPageUI extends StatefulWidget {
  const SearchPageUI({Key? key}) : super(key: key);

  @override
  _SearchPageUIState createState() => _SearchPageUIState();
}

class _SearchPageUIState extends State<SearchPageUI> {
  final SearchPageLogic _logic = SearchPageLogic();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      _searchResults = await _logic.searchUsers(query);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by username...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _logic.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("An error occurred. Please try again."));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No users found."));
                    }

                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user['username']),
                          subtitle: Text(user['bio'] ?? ''),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePageUI(userId: user['userUID']),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      title: Text(user['username']),
                      subtitle: Text(user['bio'] ?? ''),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePageUI(userId: user['userUID']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
