import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventsProvider = Provider.of<EventProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await eventsProvider.loadEvents(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: eventsProvider.events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: eventsProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventsProvider.events[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text(event['type']),
                );
              },
            ),
    );
  }
}