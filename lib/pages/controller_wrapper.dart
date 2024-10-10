import 'package:brightapp/pages/home/home_page_ui.dart';
import 'package:brightapp/pages/profile/profile_page_ui.dart';
import 'package:flutter/material.dart';

class ControllerWrapper extends StatefulWidget {
  const ControllerWrapper({super.key});

  @override
  _ControllerWrapperState createState() => _ControllerWrapperState();
}

class _ControllerWrapperState extends State<ControllerWrapper> {
  int _selectedIndex = 0;

  // Define pages using the new UI structure
  final List<Widget> _pages = [
    const HomePageUI(),  // Updated HomePage to HomePageUI
    const Center(child: Text('Search Page')),  // Placeholder for Search Page
    const Center(child: Text('Post Page')),    // Placeholder for Post Page
    const Center(child: Text('Activity Page')), // Placeholder for Activity Page
    const ProfilePageUI(),  // Updated ProfilePage to ProfilePageUI
  ];

  void _onItemTapped(int index) async {
    // If the "Post" tab is selected, open the image picker.
    if (index == 2) {
      // Logic for opening the image picker when the "Post" tab is selected
      await Navigator.pushNamed(context, '/post'); // Navigates to the image picker
    } else {
      // For other tabs, simply change the page
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
                // Direct Messages button functionality to be implemented later
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the current page based on _selectedIndex
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
}
