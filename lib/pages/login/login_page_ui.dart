import 'package:brightapp/pages/login/login_page_logic.dart';
import 'package:flutter/material.dart';

class LoginPageUI extends StatefulWidget {
  const LoginPageUI({super.key});

  @override
  State<LoginPageUI> createState() => _LoginPageUIState();
}

class _LoginPageUIState extends State<LoginPageUI> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LoginPageLogic _loginLogic = LoginPageLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEDC), // Soft beige background
      appBar: AppBar(
        title: const Text('Bright - Login'),
        backgroundColor: const Color(0xFFFFB085), // Sunset orange for AppBar
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Welcome to Bright',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB085), // Sunset orange for title
                ),
              ),
              const SizedBox(height: 20),
              if (_loginLogic.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.redAccent,
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loginLogic.errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                            color: Color(0xFF7A92A1)), // Soft blue-gray
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF7A92A1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFFFB085)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFF7A92A1)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF7A92A1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFFFB085)),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loginLogic.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _loginLogic.login(
                                    context,
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                  setState(() {});
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFFB085), // Sunset orange
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loginLogic.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Forgot Password
                    TextButton(
                      onPressed: _loginLogic.isLoading
                          ? null
                          : () {
                              _loginLogic.resetPassword(
                                context,
                                _emailController.text.trim(),
                              );
                              setState(() {});
                            },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF7A92A1), // Soft blue-gray
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                              color: Color(0xFF7A92A1)), // Soft blue-gray
                        ),
                        TextButton(
                          onPressed: _loginLogic.isLoading
                              ? null
                              : () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/register');
                                },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFFFFB085), // Sunset orange
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
