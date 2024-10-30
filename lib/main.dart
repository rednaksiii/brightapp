import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:brightapp/controllers/auth_controller.dart';
import 'package:brightapp/routes.dart';
import 'package:brightapp/pages/home/home_page_ui.dart';
import 'package:brightapp/pages/login/login_page_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BrightApp());
}

class BrightApp extends StatelessWidget {
  const BrightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'BrightApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/home',
        //home: const InitialScreen(), // Set the initial route
        routes: routes, // Define your routes here
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Check if login status is determined
        if (authController.user == null && !authController.isUserLoggedIn()) {
          return const Center(child: CircularProgressIndicator());
        } else if (authController.isUserLoggedIn()) {
          // User is logged in, navigate to home screen
          return const HomePageUI();
        } else {
          // User is not logged in, navigate to login screen
          return const LoginPageUI();
        }
      },
    );
  }
}
