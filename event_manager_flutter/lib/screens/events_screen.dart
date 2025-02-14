// lib/screens/events_screen.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:event_manager_flutter/screens/eventDetails_screen.dart';
import 'package:event_manager_flutter/screens/login_screen.dart';
import 'package:event_manager_flutter/widgets/default_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/person_provider.dart';
import '../models/person_model.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/card_builder.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  PersonModel? _currentPerson;

  // Controller for search field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEventsAndFilter();
    _searchController.addListener(() {
      // Call setState so that the Consumer rebuilds when search text changes.
      setState(() {});
    });
  }

  /// Fetches events from the backend via the provider and applies role-based filtering.
  Future<void> _loadEventsAndFilter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('Loading events and filtering');

      final personProvider =
          Provider.of<PersonProvider>(context, listen: false);
      await personProvider.loadCurrentPerson(context);
      print('Loaded current person');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      print('Got current user');

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
      final allEvents = await eventProvider.fetchAllEvents(authProvider.token!);
      final filtered = _filterEvents(events, _currentPerson!);
      print("Filtered events: $filtered");

      // Update EventProvider with filtered events
      eventProvider.setEvents(filtered, allEvents);

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

      final groupEnum = currentPerson.group!;
      final groupString = groupEnum.toString().split('.').last;
      final normalizedPersonGroup = groupString.trim().toLowerCase();
      print('Normalized Person group: "$normalizedPersonGroup"');

      final filteredEvents = events.where((event) {
        final normalizedEventGroups =
            event.groups.map((g) => g.trim().toLowerCase()).toList();
        print(
            'Event ID: ${event.id}, Name: "${event.name}", Groups: $normalizedEventGroups');

        bool isEventMatch =
            normalizedEventGroups.contains(normalizedPersonGroup);

        if (isEventMatch) {
          print('Matched Event ID: ${event.id}, Name: "${event.name}"');
          event.subevents = event.subevents.where((subEvent) {
            final normalizedSubEventGroups =
                subEvent.groups.map((g) => g.trim().toLowerCase()).toList();
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
          return true;
        } else {
          print('No match for Event ID: ${event.id}, Name: "${event.name}"');
          return false;
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).loadEvents(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).reset();
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const DefaultDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Always-visible search bar at the top
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by event name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                // Consumer for the events list
                Expanded(
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      // Use provider's events and apply search filtering dynamically
                      List<EventModel> events = eventProvider.events;
                      final query = _searchController.text.toLowerCase();
                      final filtered = events.where((event) {
                        final name = event.name.toLowerCase();
                        return name.contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'There are no events for you right now. Check back later',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return CardBuilder.createCard(
                            context: context,
                            eventProvider: eventProvider,
                            person: _currentPerson,
                            token: token,
                            event: event,
                            name: event.name ?? 'No Name',
                            type: event.type ?? 'No Type',
                            startDate: _formatDate(event.startDate.toString()),
                            endDate: _formatDate(event.endDate.toString()),
                            currentParticipants: event.currentParticipants.toString(),
                            maxParticipants: event.maxParticipants.toString(),
                            subEvents: event.subevents ?? [],
                            imagePath: event.imagePath,
                            isSubscribed: eventProvider.subscribedEventIds.contains(event.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// Helper method to format date strings.
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
