import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPageLogic {
  // Function to fetch all users for the recommendations list
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Error fetching users: $e");
      return Stream.error("Error fetching users");
    }
  }

  // Function to search for users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error searching for users: $e");
      throw Exception("Error searching for users");
    }
  }
}
