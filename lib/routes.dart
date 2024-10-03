import 'package:brightapp/pages/controller_wrapper.dart';
import 'package:brightapp/pages/login_page.dart';
import 'package:brightapp/pages/register_page.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const ControllerWrapper(),  // Set ControllerWrapper as the main home
};
