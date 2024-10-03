import 'package:brightapp/pages/login_page.dart';
import 'package:brightapp/pages/register_page.dart';
import 'package:brightapp/pages/home_page.dart';
import 'package:brightapp/pages/profile_page.dart'; // Import ProfilePage
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const HomePage(),
  '/profile': (context) => const ProfilePage(), // Add ProfilePage route
};
