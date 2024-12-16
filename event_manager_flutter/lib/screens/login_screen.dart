// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/background.mp4')
      ..initialize().then((_) {
        setState(() {}); // Update the UI when initialization is complete
        _videoController.play();
      })
      ..setLooping(true)
      ..setVolume(0); // Mute the video to allow autoplay
  }

  @override
  void dispose() {
    _videoController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        _videoController.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            : Container(color: Colors.black),
        Container(
          color: Colors.black.withOpacity(0.5), // Optional overlay
        ),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Event Manager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
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
                // TextButton(
                //   onPressed: _isLoading ? null : _register,
                //   child: Text('Register', style: TextStyle(color: Colors.white)),
                // ),
              ],
            ),
          ),
        ),
      ],
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
      print(_usernameController.text.trim());
      print(_passwordController.text.trim());

      await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        context,
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