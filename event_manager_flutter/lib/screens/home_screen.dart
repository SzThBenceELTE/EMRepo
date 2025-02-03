import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Event Manager'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Event Manager - Menu'),
            ),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                Navigator.pushNamed(context, '/events');
              },
            ),
            ListTile(
              title: const Text('People'),
              onTap: () {
                Navigator.pushNamed(context, '/people');
              },
            ),
            ListTile(
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pushNamed(context, '/calendar');
              },
            ),
            ListTile(
              title: const Text('Log out'),
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