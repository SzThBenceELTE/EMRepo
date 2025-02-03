import 'package:flutter/material.dart';
import 'package:user_frontend/pages/login_page.dart';
import 'package:user_frontend/pages/navigation_page.dart';
import 'package:user_frontend/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telco App',
      theme: ThemeData.dark(),
      home: AuthCheckPage(),
    );
  }
}

class AuthCheckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData && snapshot.data != null && snapshot.data != '') {
          return NavigationPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
