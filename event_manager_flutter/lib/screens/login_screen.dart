// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Username Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            // Password Field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            // Error Message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? CircularProgressIndicator() : Text('Login'),
            ),
            // Register Button
            Spacer(),
            TextButton(
              onPressed: _isLoading ? null : _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/events');
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    Navigator.pushNamed(context, '/register');
  }
}