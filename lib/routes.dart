// lib/routes.dart
import 'package:brightapp/pages/home_page.dart';
import 'package:brightapp/pages/login_page.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  // Add more routes as needed
};
