import 'package:brightapp/pages/controller_wrapper.dart';
import 'package:brightapp/pages/login/login_page_ui.dart';
import 'package:brightapp/pages/register/register_page_ui.dart';
import 'package:brightapp/pages/home/home_page_ui.dart';
import 'package:brightapp/pages/profile/profile_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:brightapp/pages/post_page.dart';

final Map<String, WidgetBuilder> routes = {
<<<<<<< HEAD
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const ControllerWrapper(),  // Set ControllerWrapper as the main home
  '/post': (context) => const ImagePickerPage(),
=======
  '/login': (context) => const LoginPageUI(),         // Updated LoginPage reference
  '/register': (context) => const RegisterPageUI(),   // Updated RegisterPage reference
  '/home': (context) => const ControllerWrapper(),    // Set ControllerWrapper as the main home
  '/profile': (context) => const ProfilePageUI(),     // Updated ProfilePage reference
>>>>>>> 7bfc9d42c8614d57cf7f94e15d9372f2a6afb1e5
};
