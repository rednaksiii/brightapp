import 'package:brightapp/pages/home/home_page_ui.dart';
import 'package:brightapp/pages/profile/profile_page_ui.dart';
import 'package:brightapp/pages/search/search_page_ui.dart'; // Import the search page UI
import 'package:brightapp/pages/direct_messages/direct_messages_list_ui.dart'; // Import Direct Messages List UI
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brightapp/pages/activity/activity_page_ui.dart';

class ControllerWrapper extends StatefulWidget {
  const ControllerWrapper({super.key});

  @override
  _ControllerWrapperState createState() => _ControllerWrapperState();
}

class _ControllerWrapperState extends State<ControllerWrapper> {
  int _selectedIndex = 0;

  String? _userId;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      setState(() {
        _userId = user.uid; // Store the user ID once logged in
        _updatePages(); // Update the pages list with the userId
      });
    }
  }

  void _updatePages() {
    _pages.clear();
    _pages.addAll([
      const HomePageUI(),
      const SearchPageUI(),
      const Center(child: Text('Post Page')),
      ActivityPageUI(),
      const ProfilePageUI(),
    ]);
  }

  void _onItemTapped(int index) async {
    // If the "Post" tab is selected, open the image picker.
    if (index == 2) {
      await Navigator.pushNamed(context, '/post');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _selectedIndex == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_icon.png', // Path to the app icon
                    width: 40, // Set the width for the app_icon
                    height: 40, // Set the height for the app_icon
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'BrightFeed',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ],
              )
            : _selectedIndex == 4
                ? const Text(
                    'Profile',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                : const Text(
                    'BrightApp',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
        centerTitle: true, // Center the app icon and title in the app bar
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () {
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
      body: _pages.isNotEmpty ? _pages[_selectedIndex] : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Activity'),
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
}
