// lib/screens/events_screen.dart

import 'package:event_manager_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/person_provider.dart';
import '../models/person_model.dart';
import '../models/event_model.dart';
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('loading events and filtering');

      final personProvider =
          Provider.of<PersonProvider>(context, listen: false);
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
      _currentPerson = await apiService.fetchPersonByUserId(
          currentUser.id, authProvider.token!);

      // Fetch events after obtaining currentPerson
      final events = await eventProvider.fetchEvents(authProvider.token!);
      final filtered = _filterEvents(events, _currentPerson!);
      print("Filtered events: $filtered");

      // Update EventProvider with filtered events
      eventProvider.setEvents(filtered);

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

  List<EventModel> _filterEvents(
      List<EventModel> events, PersonModel currentPerson) {
    print('_filterEvents');

    if (currentPerson.role == RoleTypeEnum.MANAGER) {
      print('Manager');
      return events;
    } else if (currentPerson.role == RoleTypeEnum.DEVELOPER &&
        currentPerson.group != null) {
      print('Developer');
      print('Person group: "${currentPerson.group}"');

      // Convert GroupTypeEnum to String before normalization
      final groupEnum = currentPerson.group!;
      final groupString = groupEnum.toString().split('.').last;
      final normalizedPersonGroup = groupString.trim().toLowerCase();
      print('Normalized Person group: "$normalizedPersonGroup"');

      // Filter events and their subevents
      final filteredEvents = events.where((event) {
        // Normalize event groups
        final normalizedEventGroups =
            event.groups.map((g) => g.trim().toLowerCase()).toList();
        print(
            'Event ID: ${event.id}, Name: "${event.name}", Groups: $normalizedEventGroups');

        bool isEventMatch =
            normalizedEventGroups.contains(normalizedPersonGroup);

        if (isEventMatch) {
          print('Matched Event ID: ${event.id}, Name: "${event.name}"');

          // Filter subevents based on group
          event.subevents = event.subevents.where((subEvent) {
            // Normalize subevent groups
            final normalizedSubEventGroups =
                subEvent.groups.map((g) => g.trim().toLowerCase()).toList();
            print(
                'SubEvent ID: ${subEvent.id}, Name: "${subEvent.name}", Groups: $normalizedSubEventGroups');

            bool isSubEventMatch =
                normalizedSubEventGroups.contains(normalizedPersonGroup);

            if (isSubEventMatch) {
              print(
                  'Matched SubEvent ID: ${subEvent.id}, Name: "${subEvent.name}"');
            } else {
              print(
                  'No match for SubEvent ID: ${subEvent.id}, Name: "${subEvent.name}"');
            }

            return isSubEventMatch;
          }).toList();

          return true; // Keep the event
        } else {
          print('No match for Event ID: ${event.id}, Name: "${event.name}"');
          return false; // Exclude the event
        }
      }).toList();

      print('Filtered events count: ${filteredEvents.length}');
      return filteredEvents;
    }

    print('No matching role or group. Returning empty list.');
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final person = _currentPerson;

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadEventsAndFilter();
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : eventProvider.events.isEmpty
              ? const Center(
                  child: Text(
                    'There are no events for you right now. Check back later',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
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
                        event.currentParticipants.toString();
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
                      margin:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Main Event Info
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // Main Event Details
                                      _buildEventDetailRow(
                                          Icons.category, type),
                                      _buildEventDetailRow(
                                          Icons.calendar_today,
                                          'Start: $startDate'),
                                      _buildEventDetailRow(
                                          Icons.calendar_today_outlined,
                                          'End: $endDate'),
                                      _buildEventDetailRow(
                                        Icons.people,
                                        'Participants: $currentParticipants / $maxParticipants',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Subscribe/Unsubscribe Button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSubscribed
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                      onPressed: () {
                                        if (person != null && token != null) {
                                          if (isSubscribed) {
                                            // Unsubscribe
                                            eventProvider
                                                .leaveMainEvent(
                                                    context,
                                                    event.id,
                                                    event.subevents)
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Unsubscribed from $name and all subevents'),
                                                ),
                                              );
                                              setState(() {});
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to unsubscribe: $error'),
                                                ),
                                              );
                                            });
                                          } else {
                                            // Subscribe
                                            eventProvider
                                                .joinEvent(context, event.id)
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Subscribed to $name'),
                                                ),
                                              );
                                              setState(() {});
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to subscribe: $error'),
                                                ),
                                              );
                                            });
                                          }
                                        }
                                      },
                                      child: Text(
                                        isSubscribed
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
                            // Right Column: Subevents
                            if (subEvents.isNotEmpty) ...[
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subevents',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 200, // Adjust as needed
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: ListView.builder(
                                        itemCount: subEvents.length,
                                        itemBuilder:
                                            (context, subIndex) {
                                          final subEvent =
                                              subEvents[subIndex];
                                          final subName = subEvent.name ??
                                              'No Name';
                                          final subType = subEvent.type ??
                                              'No Type';
                                          final subStartDate = _formatDate(
                                              subEvent.startDate
                                                  .toString());
                                          final subEndDate = _formatDate(
                                              subEvent.endDate.toString());
                                          final subCurrentParticipants =
                                              subEvent.currentParticipants
                                                  .toString();
                                          final subMaxParticipants =
                                              subEvent.maxParticipants
                                                      .toString() ??
                                                  'N/A';
                                          final subIsSubscribed = eventProvider
                                              .subscribedEventIds
                                              .contains(subEvent.id);

                                          return ExpansionTile(
                                            title: Text(
                                              subName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    _buildEventDetailRow(
                                                        Icons.category,
                                                        subType),
                                                    _buildEventDetailRow(
                                                        Icons
                                                            .calendar_today,
                                                        'Start: $subStartDate'),
                                                    _buildEventDetailRow(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      'End: $subEndDate',
                                                    ),
                                                    _buildEventDetailRow(
                                                      Icons.people,
                                                      'Participants: $subCurrentParticipants / $subMaxParticipants',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    // Subscribe/Unsubscribe Button for Subevent
                                                    Align(
                                                      alignment: Alignment
                                                          .centerRight,
                                                      child:
                                                          ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              subIsSubscribed
                                                                  ? Colors
                                                                      .red
                                                                  : Colors
                                                                      .blue,
                                                        ),
                                                        onPressed: isSubscribed
                                                            ? () {
                                                                if (person !=
                                                                        null &&
                                                                    token !=
                                                                        null) {
                                                                  if (subIsSubscribed) {
                                                                    // Unsubscribe from subevent
                                                                    eventProvider
                                                                        .leaveEvent(
                                                                            context,
                                                                            subEvent.id)
                                                                        .then((_) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('Unsubscribed from $subName'),
                                                                        ),
                                                                      );
                                                                      setState(
                                                                          () {});
                                                                    }).catchError(
                                                                            (error) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('Failed to unsubscribe: $error'),
                                                                        ),
                                                                      );
                                                                    });
                                                                  } else {
                                                                    // Subscribe to subevent
                                                                    eventProvider
                                                                        .joinEvent(
                                                                            context,
                                                                            subEvent.id)
                                                                        .then((_) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('Subscribed to $subName'),
                                                                        ),
                                                                      );
                                                                      setState(
                                                                          () {});
                                                                    }).catchError(
                                                                            (error) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('Failed to subscribe: $error'),
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
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message at the top
                  Text(
                    'Welcome, ${_currentPerson?.firstName} ${_currentPerson?.surname}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  // Role and Group at the bottom
                  Text(
                    'Role: ${_currentPerson?.role.toString().split('.').last}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (_currentPerson?.role == RoleTypeEnum.DEVELOPER &&
                      _currentPerson?.group != null)
                    Text(
                      'Group: ${_currentPerson?.group.toString().split('.').last}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
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
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}