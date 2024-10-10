import 'package:brightapp/pages/register/register_page_logic.dart';
import 'package:flutter/material.dart';

class RegisterPageUI extends StatelessWidget {
  const RegisterPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterPageLogic registerLogic = RegisterPageLogic(context); // Initialize logic with context

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email TextField
            TextField(
              controller: registerLogic.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            // Password TextField
            TextField(
              controller: registerLogic.passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            // Register Button
            ElevatedButton(
              onPressed: registerLogic.register, // Call register method from logic
              child: const Text('Register'),
            ),
            // Display error message if it exists
            if (registerLogic.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  registerLogic.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            // Navigate to Login Page
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
