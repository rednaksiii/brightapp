// lib/main.dart
import 'package:brightapp/controllers/auth_controller.dart';
import 'package:brightapp/pages/home_page.dart';
import 'package:brightapp/pages/login_page.dart';
import 'package:brightapp/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your Firebase options if using FlutterFire CLI
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Uncomment and provide options if not using default
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BrightApp());
}

class BrightApp extends StatelessWidget {
  const BrightApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'Bright',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ControllerWrapper(),
        routes: routes,
      ),
    );
  }
}

class ControllerWrapper extends StatelessWidget {
  const ControllerWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    if (authController.user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
