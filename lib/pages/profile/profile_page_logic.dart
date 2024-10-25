// for now: import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageLogic {
  String _userName = 'Default Username';
  String _userBio = 'Default Bio';

  // Getter for userName
  String get userName => _userName;

  // Setter for userName
  set userName(String value) {
    _userName = value;
  }

  // Getter for userBio
  String get userBio => _userBio;

  // Setter for userBio
  set userBio(String value) {
    _userBio = value;
  }
}

