import 'package:flutter/material.dart';
import 'package:brightapp/pages/login_page.dart';
import 'package:brightapp/pages/register_page.dart';
import 'package:brightapp/pages/home_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const HomePage(),
};
