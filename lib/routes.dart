import 'package:brightapp/pages/controller_wrapper.dart';
import 'package:brightapp/pages/login/login_page_ui.dart';
import 'package:brightapp/pages/register/register_page_ui.dart';
import 'package:brightapp/pages/home/home_page_ui.dart';
import 'package:brightapp/pages/profile/profile_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:brightapp/pages/post/post_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPageUI(),
  '/register': (context) => const RegisterPageUI(),
  '/home': (context) => const ControllerWrapper(),  // Set ControllerWrapper as the main home
  '/post': (context) => const ImagePickerPage(),
};
