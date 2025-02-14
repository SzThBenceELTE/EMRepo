// lib/screens/people_screen.dart
import 'package:event_manager_flutter/screens/login_screen.dart';
import 'package:event_manager_flutter/widgets/default_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/person_provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await personProvider.loadPeople(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personProvider = Provider.of<PersonProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: personProvider.people.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: personProvider.people.length,
              itemBuilder: (context, index) {
                final person = personProvider.people[index];
                final firstName = person['firstName'] ?? '';
                final surname = person['surname'] ?? '';
                final role = person['role'] ?? 'Unknown Role';
                final group = person['group'] ?? 'No Group';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $surname',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('Role: $role'),
                        Text('Group: $group'),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Example logout button, if needed:
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: const Icon(Icons.logout),
      ),
      drawer: const DefaultDrawer(),
    );
  }
}
