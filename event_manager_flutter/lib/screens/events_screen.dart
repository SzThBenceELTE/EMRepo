// lib/screens/events_screen.dart

import 'package:event_manager_flutter/screens/login_screen.dart';
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
    _loadEventsAndSubscriptions();
  }

  Future<void> _loadEventsAndSubscriptions() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadEvents(context);
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final person = authProvider.currentPerson;

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadEventsAndSubscriptions();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              eventProvider.reset(); // Clear event data
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: eventProvider.events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                final name = event['name'] ?? 'No Name';
                final type = event['type'] ?? 'No Type';
                final startDate = _formatDate(event['startDate']);
                final endDate = _formatDate(event['endDate']);
                final maxParticipants =
                    event['maxParticipants']?.toString() ?? 'N/A';
                final isSubscribed =
                    eventProvider.subscribedEventIds.contains(event['id']);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.category,
                                size: 16, color: Colors.grey[700]),
                            SizedBox(width: 5),
                            Text(
                              type,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[700]),
                            SizedBox(width: 5),
                            Text(
                              'Start: $startDate',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: Colors.grey[700]),
                            SizedBox(width: 5),
                            Text(
                              'End: $endDate',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.people,
                                size: 16, color: Colors.grey[700]),
                            SizedBox(width: 5),
                            Text(
                              'Max Participants: $maxParticipants',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSubscribed ? Colors.red : Colors.blue,
                            ),
                            onPressed: () {
                              if (person != null && token != null) {
                                if (isSubscribed) {
                                  // Unsubscribe
                                  eventProvider.leaveEvent(
                                      context, event['id']).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Unsubscribed from $name'),
                                      ),
                                    );
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to unsubscribe: $error'),
                                      ),
                                    );
                                  });
                                } else {
                                  // Subscribe
                                  eventProvider.joinEvent(
                                      context, event['id']).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Subscribed to $name'),
                                      ),
                                    );
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to subscribe: $error'),
                                      ),
                                    );
                                  });
                                }
                              }
                            },
                            child: Text(
                              isSubscribed ? 'Unsubscribe' : 'Subscribe',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Event Manager - Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
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

  /// Helper method to format date strings
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}