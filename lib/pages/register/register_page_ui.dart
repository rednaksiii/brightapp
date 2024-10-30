import 'package:brightapp/pages/register/register_page_logic.dart';
import 'package:flutter/material.dart';
import '/controllers/square_tile.dart';

class RegisterPageUI extends StatelessWidget {
  const RegisterPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterPageLogic registerLogic = RegisterPageLogic(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDEEDC), // Light beige background
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFFFFB085), // Sunset orange for AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFB085), // Sunset orange
              ),
            ),
            const SizedBox(height: 20),
            // Email TextField
            TextField(
              controller: registerLogic.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    const TextStyle(color: Color(0xFF7A92A1)), // Soft blue-gray
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A92A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFB085)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            // Password TextField
            TextField(
              controller: registerLogic.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF7A92A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A92A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFB085)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Confirm Password TextField
            TextField(
              controller: registerLogic.confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(color: Color(0xFF7A92A1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7A92A1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFFB085)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerLogic.register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB085), // Sunset orange
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
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
            const SizedBox(height: 16),
            // Navigate to Login Page
            TextButton(
              onPressed: registerLogic.navigateToLogin,
              child: const Text(
                'Already have an account? Login',
                style: TextStyle(
                  color: Color(0xFF7A92A1), // Soft blue-gray
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Divider with "Or continue with" text
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
            const SizedBox(height: 30),
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
