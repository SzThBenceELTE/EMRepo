// lib/widgets/event_card.dart

import 'package:event_manager_flutter/providers/person_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/person_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../screens/eventDetails_screen.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isVisible;

  const EventCard({
    Key? key,
    required this.event,
    required this.isVisible,
  }) : super(key: key);

  /// Helper method to format date strings
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  /// Builds the event detail row with an icon and text
  Widget _buildEventDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final person = Provider.of<PersonProvider>(context, listen: false).currentPerson;

    final name = event.name ?? 'No Name';
    final type = event.type ?? 'No Type';
    final startDate = _formatDate(event.startDate.toString());
    final endDate = _formatDate(event.endDate.toString());
    final currentParticipants = event.currentParticipants.toString();
    final maxParticipants = event.maxParticipants.toString() ?? 'N/A';
    final isSubscribed = eventProvider.subscribedEventIds.contains(event.id);
    final subEvents = event.subevents ?? [];
    final imagePath = event.imagePath;
    print('Event ID: ${event.id}, Name: $name, Image: $imagePath');

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Card(
        color: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
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
            padding: EdgeInsets.all(15),
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
                      // Event details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color over image
                            ),
                          ),
                          SizedBox(height: 10),
                          // Main Event Details
                          _buildEventDetailRow(Icons.category, type),
                          _buildEventDetailRow(Icons.calendar_today, 'Start: $startDate'),
                          _buildEventDetailRow(Icons.calendar_today_outlined, 'End: $endDate'),
                          _buildEventDetailRow(
                            Icons.people,
                            'Participants: $currentParticipants / $maxParticipants',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Subscribe/Unsubscribe and Details Buttons
                      Row(
                        children: [
                          // Subscribe/Unsubscribe Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSubscribed ? Colors.red : Colors.blue,
                            ),
                            onPressed: () {
                              if (person != null && token != null) {
                                if (isSubscribed) {
                                  // Unsubscribe
                                  eventProvider
                                      .leaveMainEvent(context, event.id, event.subevents)
                                      .then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Unsubscribed from $name and all subevents'),
                                      ),
                                    );
                                    // Optionally, you can trigger a state update or callback here
                                  }).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to unsubscribe: $error'),
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
                                    // Optionally, you can trigger a state update or callback here
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
                            child: Icon(
                              isSubscribed ? Icons.remove : Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          // Details Button
                          ElevatedButton(
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
                            child: Icon(
                              Icons.book,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subevents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color over image
                          ),
                        ),
                        SizedBox(height: 5),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white, // Text color over image
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildEventDetailRow(
                                            Icons.category, subType),
                                        _buildEventDetailRow(
                                            Icons.calendar_today, 'Start: $subStartDate'),
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
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: subIsSubscribed
                                                    ? Colors.red
                                                    : Colors.blue,
                                              ),
                                              onPressed: () {
                                                if (person != null &&
                                                    token != null) {
                                                  if (subIsSubscribed) {
                                                    // Unsubscribe from subevent
                                                    eventProvider
                                                        .leaveEvent(
                                                            context, subEvent.id)
                                                        .then((_) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Unsubscribed from $subName'),
                                                        ),
                                                      );
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
                                                    // Subscribe to subevent
                                                    eventProvider
                                                        .joinEvent(
                                                            context, subEvent.id)
                                                        .then((_) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Subscribed to $subName'),
                                                        ),
                                                      );
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
                                              child: Icon(
                                                subIsSubscribed
                                                    ? Icons.remove
                                                    : Icons.add,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
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
                                              child: Icon(
                                                Icons.book,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
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
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      }
    }
    