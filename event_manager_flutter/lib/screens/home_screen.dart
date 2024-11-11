import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Event Manager'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Event Manager'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Navigate to Profile Screen
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Navigate to Settings Screen
              },
            ),
            ListTile(
              title: Text('Events'),
              onTap: () {
                Navigator.pushNamed(context, '/events');
              },
            ),
            ListTile(
              title: Text('People'),
              onTap: () {
                Navigator.pushNamed(context, '/people');
              },
            ),
            ListTile(
              title: Text('Log out'),
              onTap: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}