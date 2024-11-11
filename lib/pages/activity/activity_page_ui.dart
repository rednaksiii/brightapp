// Import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityPageUI extends StatelessWidget {
  const ActivityPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                leading: Icon(Icons.notifications, color: Colors.blue),
                title: Text(doc['title'] ?? 'Notification'),
                subtitle: Text(doc['message'] ?? 'No message'),
                trailing: Text(doc['timestamp'].toDate().toString()), // Adjust formatting as needed
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
