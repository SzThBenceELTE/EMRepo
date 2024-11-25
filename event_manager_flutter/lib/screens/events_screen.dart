// lib/screens/events_screen.dart

import 'package:event_manager_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/person_provider.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../models/user_model.dart';
import '../models/person_model.dart';
import '../services/api_service.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  PersonModel? _currentPerson;

  @override
  void initState() {
    super.initState();
    _loadEventsAndFilter();
  }

  /// Fetches events from the backend and applies role-based filtering.
  Future<void> _loadEventsAndFilter() async {
    try {


      print('loading events and filtering');
      
      final personProvider = Provider.of<PersonProvider>(context, listen: false);
      await personProvider.loadCurrentPerson(context);
      print('loaded current person');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      print('got current user');

      if (currentUser == null) {
        throw Exception('No authenticated user found.');
      }

      // Fetch subscribed event IDs after loading current person
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.fetchSubscribedEventIds(context);
      print('Fetched subscribed event IDs');

      // Fetch the associated Person
      final apiService = ApiService();
      //print('currentUser: ${currentUser}');
      //print('authProvider.token: ${authProvider.token}');
      _currentPerson = await apiService.fetchPersonByUserId(currentUser.id, authProvider.token!);
      //print("Current Person: $_currentPerson");

      

      // Fetch events after obtaining currentPerson
      final events = await Provider.of<EventProvider>(context, listen: false).fetchEvents(authProvider.token!);
      //print("Events after fetch: $events");

      final filtered = _filterEvents(events, _currentPerson!);
      print("Filtered events: $filtered");

      // Update EventProvider with filtered events
      Provider.of<EventProvider>(context, listen: false).setEvents(filtered);

      setState(() {
        _isLoading = false;
      });

      print("Events loaded and filtered successfully.");
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching events: $error';
        _isLoading = false;
      });
      print('Error fetching events: $error');
    }
  }

  List<EventModel> _filterEvents(List<EventModel> events, PersonModel currentPerson) {
  print('_filterEvents');

  if (currentPerson.role == RoleTypeEnum.MANAGER) {
    print('Manager');
    return events;
  } else if (currentPerson.role == RoleTypeEnum.DEVELOPER && currentPerson.group != null) {
    print('Developer');
    print('Person group: "${currentPerson.group}"');

    // Convert GroupTypeEnum to String before normalization
    final groupEnum = currentPerson.group!;
    final groupString = groupEnum.toString().split('.').last; // Extract enum name as String
    final normalizedPersonGroup = groupString.trim().toLowerCase();
    print('Normalized Person group: "$normalizedPersonGroup"');

    // Filter events where any of the event's groups match the person's group
    final filteredEvents = events.where((event) {
      // Normalize each group in the event
      final normalizedEventGroups = event.groups.map((g) => g.trim().toLowerCase()).toList();
      print('Event ID: ${event.id}, Name: "${event.name}", Groups: $normalizedEventGroups');

      bool isMatch = normalizedEventGroups.contains(normalizedPersonGroup);

      if (isMatch) {
        print('Matched Event ID: ${event.id}, Name: "${event.name}"');
      } else {
        print('No match for Event ID: ${event.id}, Name: "${event.name}"');
      }

      return isMatch;
    }).toList();

    print('Filtered events count: ${filteredEvents.length}');
    return filteredEvents;
  }

  print('No matching role or group. Returning empty list.');
  return [];
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
    final person = authProvider.currentUser;

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
                final name = event.name ?? 'No Name';
                final type = event.type ?? 'No Type';
                final startDate = _formatDate(event.startDate.toString());
                final endDate = _formatDate(event.endDate.toString());
                final currentParticipants =
                    event.currentParticipants.toString() ?? '0';
                final maxParticipants =
                    event.maxParticipants.toString() ?? 'N/A';
                final isSubscribed =
                    eventProvider.subscribedEventIds.contains(event.id);
                final subEvents = event.subevents ?? [];


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
                              'Current Participants: $currentParticipants',
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
                        // Display each subevent with its own ExpansionTile
                        ...subEvents.map((subEvent) {
                          final subName = subEvent.name ?? 'No Name';
                          final subType = subEvent.type ?? 'No Type';
                          final subStartDate =
                              _formatDate(subEvent.startDate.toString());
                          final subEndDate = _formatDate(subEvent.endDate.toString());
                          final subCurrentParticipants =
                              subEvent.currentParticipants.toString() ?? '0';
                          final subMaxParticipants =
                              subEvent.maxParticipants.toString() ?? 'N/A';
                          final subIsSubscribed = eventProvider
                              .subscribedEventIds
                              .contains(subEvent.id);

                          return ExpansionTile(
                            title: Text(
                              subName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Subevent Type
                                    Row(
                                      children: [
                                        Icon(Icons.category,
                                            size: 14, color: Colors.grey[700]),
                                        SizedBox(width: 5),
                                        Text(
                                          subType,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Subevent Start Date
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey[700]),
                                        SizedBox(width: 5),
                                        Text(
                                          'Start: $subStartDate',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Subevent End Date
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined,
                                            size: 14, color: Colors.grey[700]),
                                        SizedBox(width: 5),
                                        Text(
                                          'End: $subEndDate',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Subevent Current Participants
                                    Row(
                                      children: [
                                        Icon(Icons.people,
                                            size: 14, color: Colors.grey[700]),
                                        SizedBox(width: 5),
                                        Text(
                                          'Current Participants: $subCurrentParticipants',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Subevent Max Participants
                                    Row(
                                      children: [
                                        Icon(Icons.people,
                                            size: 14, color: Colors.grey[700]),
                                        SizedBox(width: 5),
                                        Text(
                                          'Max Participants: $subMaxParticipants',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Subscribe/Unsubscribe Button for Subevent
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: subIsSubscribed
                                              ? Colors.red
                                              : Colors.blue,
                                        ),
                                        onPressed: isSubscribed
                                            ? () {
                                                if (person != null &&
                                                    token != null) {
                                                  if (subIsSubscribed) {
                                                    // Unsubscribe from Subevent
                                                    eventProvider
                                                        .leaveEvent(
                                                            context,
                                                            subEvent.id)
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Unsubscribed from $subName'),
                                                        ),
                                                      );
                                                    }).catchError((error) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Failed to unsubscribe: $error'),
                                                        ),
                                                      );
                                                    });
                                                  } else {
                                                    // Subscribe to Subevent
                                                    eventProvider
                                                        .joinEvent(
                                                            context,
                                                            subEvent.id)
                                                        .then((_) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Subscribed to $subName'),
                                                        ),
                                                      );
                                                    }).catchError((error) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Failed to subscribe: $error'),
                                                        ),
                                                      );
                                                    });
                                                  }
                                                }
                                              }
                                            : null,
                                        child: Text(
                                          subIsSubscribed
                                              ? 'Unsubscribe'
                                              : 'Subscribe',
                                          style:
                                              TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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
                                  eventProvider.leaveMainEvent(
                                      context, event.id, event.subevents).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Unsubscribed from $name and all subevents'),
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
                                      context, event.id).then((_) {
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