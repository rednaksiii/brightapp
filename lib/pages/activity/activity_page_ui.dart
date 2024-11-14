import 'package:flutter/material.dart';
import 'package:brightapp/pages/activity/notification_service.dart'; // Import the notification service

class ActivityPageUI extends StatefulWidget {
  const ActivityPageUI({super.key});

  @override
  _ActivityPageUIState createState() => _ActivityPageUIState();
}

class _ActivityPageUIState extends State<ActivityPageUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet."))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}
