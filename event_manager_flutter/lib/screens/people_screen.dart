import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/person_provider.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await personProvider.loadEvents(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personProvider = Provider.of<PersonProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
      ),
      body: personProvider.events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: personProvider.events.length,
              itemBuilder: (context, index) {
                
                final event = personProvider.events[index];
                final firstName = event['firstName'] ?? '';
                final surname = event['surname'] ?? '';
                final role = event['role'] ?? 'Unknown Role';
                final group = event['group'] ?? 'No Group';
                 return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $surname',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text('Role: $role'),
                        Text('Group: $group'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}