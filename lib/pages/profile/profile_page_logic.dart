import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageLogic {
  final User? user = FirebaseAuth.instance.currentUser;

  // User profile information
  String get userName => user?.displayName ?? "User";
  String get userEmail => user?.email ?? "No email available";
  String get userProfileImage => user?.photoURL ?? 'https://via.placeholder.com/150';

  // Placeholder data for user stats
  int get postsCount => 0; // Set to 0 for now; will update once we implement post tracking
  int get followersCount => 0; // Placeholder for followers count
  int get followingCount => 0; // Placeholder for following count
}
