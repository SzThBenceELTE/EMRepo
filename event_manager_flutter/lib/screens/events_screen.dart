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

  // Keep both lists
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  List<bool> _visibleList = [];

  // Controller for search field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEventsAndFilter();
    _searchController.addListener(_filterByName);
  }

  /// Initialize the visibility list after loading events
  void _initializeVisibility() {
    _visibleList = List<bool>.filled(_allEvents.length, false);
    // Trigger fade-in for each card with a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFadeInAnimations();
    });
  }

  /// Start fade-in animations sequentially
  void _startFadeInAnimations() {
    for (int i = 0; i < _visibleList.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) {
          setState(() {
            _visibleList[i] = true;
          });
        }
      });
    }
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
      final allEvents = await eventProvider.fetchAllEvents(authProvider.token!);
      final filtered = _filterEvents(events, _currentPerson!);
      print("Filtered events: $filtered");

      // Update EventProvider with filtered events
      eventProvider.setEvents(filtered, allEvents);

      setState(() {
        _allEvents = filtered;
        _filteredEvents = List.from(filtered);
        _isLoading = false;
      });

      _initializeVisibility();

      print("Events loaded and filtered successfully.");
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching events: $error';
        _isLoading = false;
      });
      print('Error fetching events: $error');
    }
  }

  void _filterByName() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final name = event.name.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
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
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadEventsAndFilter();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Search field on top
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
                Expanded(
                  child: _filteredEvents.isEmpty
                      ? const Center(
                          child: Text(
                            'There are no events for you right now. Check back later',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            final isVisible = index < _visibleList.length
                                ? _visibleList[index]
                                : false;

                            final name = event.name ?? 'No Name';
                            final type = event.type ?? 'No Type';
                            final startDate =
                                _formatDate(event.startDate.toString());
                            final endDate =
                                _formatDate(event.endDate.toString());
                            final currentParticipants =
                                event.currentParticipants.toString();
                            final maxParticipants =
                                event.maxParticipants.toString() ?? 'N/A';
                            final isSubscribed = eventProvider
                                .subscribedEventIds
                                .contains(event.id);
                            final subEvents = event.subevents ?? [];
                            final imagePath = event.imagePath;
                            print(
                                'Event ID: ${event.id}, Name: $name, Image: $imagePath');
                            final imageData = event.imageData;

                            // Decode Base64 image data if available
                            // Uint8List? decodedImage;
                            // if (imageData != null) {
                            //   try {
                            //     decodedImage = base64Decode(imageData.split(',')[1]);
                            //   } catch (e) {
                            //     print('Error decoding imageData for event ID ${event.id}: $e');
                            //     decodedImage = null;
                            //   }
                            // }

                           return CardBuilder.createCard(
                              context: context,
                              eventProvider: eventProvider,
                              person: person,
                              token: token,
                              event: event,
                              name: name,
                              type: type,
                              startDate: startDate,
                              endDate: endDate,
                              currentParticipants: currentParticipants,
                              maxParticipants: maxParticipants,
                              subEvents: subEvents,
                              imagePath: imagePath,
                              isSubscribed: isSubscribed,
                            );
                            
                          },
                        ),
                ),
              ],
            ),
      drawer: const DefaultDrawer(),
    );
  }

  Card _createCard(
                  EventProvider eventProvider,
                  BuildContext context,
                  PersonModel? person,
                  String? token,
                  EventModel event, 
                  String name,
                  String type,
                  String startDate,
                  String endDate,
                  String currentParticipants,
                  String maxParticipants,
                  List<EventModel> subEvents,
                  String? imagePath,
                  bool isSubscribed) {
    return Card(
      color: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(10),
          image: (imagePath != null && imagePath.isNotEmpty)
              ? DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // Handle image loading error
                  },
                )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.65)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Main Event Info
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Removed Image.network as it's now a background
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color over image
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Main Event Details
                        _buildEventDetailRow(Icons.category, type),
                        _buildEventDetailRow(
                            Icons.calendar_today, 'Start: $startDate'),
                        _buildEventDetailRow(
                            Icons.calendar_today_outlined, 'End: $endDate'),
                        _buildEventDetailRow(
                          Icons.people,
                          'Participants: $currentParticipants / $maxParticipants',
                        ),
                        // if (decodedImage != null)
                        //   Image.memory(
                        //     decodedImage,
                        //     fit: BoxFit.cover,
                        //     errorBuilder: (context, error, stackTrace) {
                        //       return Text('Error loading image');
                        //     },
                        //   )
                        // else
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Subscribe/Unsubscribe Button
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSubscribed ? Colors.red : Colors.blue,
                            ),
                            onPressed: () {
                              if (person != null && token != null) {
                                if (isSubscribed) {
                                  // Unsubscribe
                                  eventProvider
                                      .leaveMainEvent(
                                          context, event.id, event.subevents)
                                      .then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Unsubscribed from $name and all subevents'),
                                      ),
                                    );
                                    setState(() {});
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Subscribed to $name'),
                                      ),
                                    );
                                    setState(() {});
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to subscribe: $error'),
                                      ),
                                    );
                                  });
                                }
                              }
                            },
                            child: Icon(
                              isSubscribed ? Icons.remove : Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              // Navigate to the event details page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                      event: event, token: token!),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.book,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right Column: Subevents
              if (subEvents.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subevents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color over image
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 200, // Adjust as needed
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: ListView.builder(
                          itemCount: subEvents.length,
                          itemBuilder: (context, subIndex) {
                            final subEvent = subEvents[subIndex];
                            final subName = subEvent.name ?? 'No Name';
                            final subType = subEvent.type ?? 'No Type';
                            final subStartDate =
                                _formatDate(subEvent.startDate.toString());
                            final subEndDate =
                                _formatDate(subEvent.endDate.toString());
                            final subCurrentParticipants =
                                subEvent.currentParticipants.toString();
                            final subMaxParticipants =
                                subEvent.maxParticipants.toString() ?? 'N/A';
                            final subIsSubscribed = eventProvider
                                .subscribedEventIds
                                .contains(subEvent.id);
                            final subImagePath = subEvent.imagePath;

                            return ExpansionTile(
                              title: Text(
                                subName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white, // Text color over image
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEventDetailRow(
                                          Icons.category, subType),
                                      _buildEventDetailRow(Icons.calendar_today,
                                          'Start: $subStartDate'),
                                      _buildEventDetailRow(
                                        Icons.calendar_today_outlined,
                                        'End: $subEndDate',
                                      ),
                                      _buildEventDetailRow(
                                        Icons.people,
                                        'Participants: $subCurrentParticipants / $subMaxParticipants',
                                      ),
                                      const SizedBox(height: 10),
                                      // Subscribe/Unsubscribe Button for Subevent
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: [
                                            ElevatedButton(
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
                                                          // Unsubscribe from subevent
                                                          eventProvider
                                                              .leaveEvent(
                                                                  context,
                                                                  subEvent.id)
                                                              .then((_) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Unsubscribed from $subName'),
                                                              ),
                                                            );
                                                            setState(() {});
                                                          }).catchError(
                                                                  (error) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Failed to unsubscribe: $error'),
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
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Subscribed to $subName'),
                                                              ),
                                                            );
                                                            setState(() {});
                                                          }).catchError(
                                                                  (error) {
                                                            ScaffoldMessenger
                                                                    .of(context)
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
                                              child: Icon(
                                                isSubscribed
                                                    ? Icons.remove
                                                    : Icons.add,
                                                color: Colors.white,
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () {
                                                // Navigate to the event details page
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EventDetailsScreen(
                                                            event: event,
                                                            token: token!),
                                                  ),
                                                );
                                              },
                                              child: const Icon(
                                                Icons.book,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // View Details Button
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
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
