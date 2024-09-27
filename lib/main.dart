import 'package:flutter/material.dart';

void main() => runApp(InstagramClone());

class InstagramClone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.pinkAccent, // Used to replace accentColor
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FeedPage(),
    SearchPage(),
    PostPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Brigsht',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Billabong',
            fontSize: 32.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
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

// FeedPage where the image will be displayed
class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        PostItem(
          username: 'johhny',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/1/14/Desert_Dawn.jpg',
        ),
        // You can add more posts here as needed
      ],
    );
  }
}

// A single post in the feed
class PostItem extends StatelessWidget {
  final String username;
  final String imageUrl;

  PostItem({required this.username, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              SizedBox(width: 10),
              Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.more_vert),
            ],
          ),
        ),
        Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.favorite_border),
              SizedBox(width: 15),
              Icon(Icons.chat_bubble_outline),
              SizedBox(width: 15),
              Icon(Icons.send),
              Spacer(),
              Icon(Icons.bookmark_border),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Liked by user1 and others', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            '$username Lorem ipsum dolor sit amet.',
            style: TextStyle(color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// Mock Search Page
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Page'));
  }
}

// Mock Post Page
class PostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Post Page'));
  }
}

// Mock Notifications Page
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications Page'));
  }
}

// Mock Profile Page
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile Page'));
  }
}
