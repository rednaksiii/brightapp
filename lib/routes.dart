import 'package:brightapp/pages/controller_wrapper.dart';
import 'package:brightapp/pages/login/login_page_ui.dart';
import 'package:brightapp/pages/register/register_page_ui.dart';
import 'package:brightapp/pages/profile/profile_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:brightapp/pages/post/post_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPageUI(),         // Updated LoginPage reference
  '/register': (context) => const RegisterPageUI(),   // Updated RegisterPage reference
  '/home': (context) => const ControllerWrapper(),    // Set ControllerWrapper as the main home
  '/profile': (context) => const ProfilePageUI(),     // Updated ProfilePage reference
  '/post': (context) => const ImagePickerPage(),
};
