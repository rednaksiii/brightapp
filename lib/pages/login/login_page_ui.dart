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

  // Instantiate the backend logic class
  final LoginPageLogic _loginLogic = LoginPageLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bright - Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Welcome to Bright',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
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
                        child: _loginLogic.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Login'),
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
                      child: const Text('Forgot Password?'),
                    ),
                    const SizedBox(height: 20),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: _loginLogic.isLoading
                              ? null
                              : () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/register');
                                },
                          child: const Text('Register'),
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
