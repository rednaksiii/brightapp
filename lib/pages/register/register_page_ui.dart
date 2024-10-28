import 'package:brightapp/pages/register/register_page_logic.dart';
import 'package:flutter/material.dart';

class RegisterPageUI extends StatefulWidget {
  const RegisterPageUI({super.key});

  @override
  _RegisterPageUIState createState() => _RegisterPageUIState();
}

class _RegisterPageUIState extends State<RegisterPageUI> {
  late RegisterPageLogic registerLogic;

  @override
  void initState() {
    super.initState();
    registerLogic = RegisterPageLogic(context);
  }

  @override
  void dispose() {
    registerLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: registerLogic.usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (lowercase)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  registerLogic.validateUsername(value); // Validate the username
                });
              },
            ),
            if (registerLogic.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  registerLogic.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: registerLogic.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: registerLogic.passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                registerLogic.register();
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: registerLogic.navigateToLogin,
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
