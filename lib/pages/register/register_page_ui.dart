import 'package:brightapp/pages/register/register_page_logic.dart';
import 'package:flutter/material.dart';
import '/controllers/square_tile.dart';

class RegisterPageUI extends StatelessWidget {
  const RegisterPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterPageLogic registerLogic =
        RegisterPageLogic(context); // Initialize logic with context

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

            const SizedBox(height: 16),
            TextField(
              controller: registerLogic.confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 16.0),
            // Register Button
            ElevatedButton(
              onPressed:
                  registerLogic.register, // Call register method from logic
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

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.8,
                      color: Colors.grey[400],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.8,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Google and Facebook sign-in buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Sign-In Button
                SquareTile(
                  imagePath: 'assets/images/google.png',
                  onTap: () async {
                    await registerLogic.signInWithGoogle();
                    if (registerLogic.errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(registerLogic.errorMessage)),
                      );
                    }
                  },
                ),
                const SizedBox(width: 15),
                // Facebook Sign-In Button
                SquareTile(
                  imagePath: 'assets/images/facebook.png',
                  onTap: () async {
                    await registerLogic.signInWithFacebook();
                    if (registerLogic.errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(registerLogic.errorMessage)),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
