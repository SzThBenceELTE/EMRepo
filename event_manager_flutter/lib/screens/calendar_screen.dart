import 'package:event_manager_flutter/screens/eventDetails_screen.dart';
import 'package:event_manager_flutter/widgets/default_drawer.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../models/person_model.dart';
import '../providers/auth_provider.dart';
import '../providers/person_provider.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<EventModel>> _events;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = true;
  String? _errorMessage;
  PersonModel? _currentPerson;
  @override
  void initState() {
    super.initState();
    final events = Provider.of<EventProvider>(context, listen: false).events;
    
    _events = {};
    for (var event in events) {
      DateTime eventDate = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      if (_events[eventDate] == null) {
        _events[eventDate] = [event];
      } else {
        _events[eventDate]!.add(event);
      }
    }

    _loadPerson();

  }

  Future<void> _loadPerson() async {
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

 // Utility function to normalize DateTime (remove time components)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  

  List<EventModel> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }
  

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final person = _currentPerson;
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders<EventModel>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return SizedBox();

                // Get the EventProvider so we can check subscription status.
                final eventProvider = Provider.of<EventProvider>(context, listen: false);

                // Create a list of dots (one for each event on this day)
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.map((event) {
                      // Determine dot color based on subscription status.
                      // You can customize these colors as needed.
                      final isSubscribed = eventProvider.subscribedEventIds.contains(event.id);
                      final dotColor = isSubscribed ? Colors.green : Colors.red;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _getEventsForDay(_selectedDay).isEmpty
    ? Center(child: Text('No events for this day'))
    : ListView.builder(
        itemCount: _getEventsForDay(_selectedDay).length,
        itemBuilder: (context, index) {
          final event = _getEventsForDay(_selectedDay)[index];
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
          final imagePath = event.imagePath;
          print(imagePath);
          print('Event ID: ${event.id}, Name: $name, Image: $imagePath');
          final imageData = event.imageData;


          return Card(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Removed Image.network as it's now a background
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Text color over image
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
                                    Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSubscribed
                                                  ? Colors.red
                                                  : Colors.blue,
                                            ),
                                            onPressed: () {
                                              if (person != null &&
                                                  token != null) {
                                                if (isSubscribed) {
                                                  // Unsubscribe
                                                  eventProvider
                                                      .leaveMainEvent(
                                                          context,
                                                          event.id,
                                                          event.subevents)
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Unsubscribed from $name and all subevents'),
                                                      ),
                                                    );
                                                    setState(() {});
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
                                                  // Subscribe
                                                  eventProvider
                                                      .joinEvent(
                                                          context, event.id)
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Subscribed to $name'),
                                                      ),
                                                    );
                                                    setState(() {});
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
                                            },
                                            child: Text(
                                              isSubscribed
                                                  ? 'Unsubscribe'
                                                  : 'Subscribe',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5)),
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
                                                  builder: (context) =>
                                                      EventDetailsScreen(
                                                          event: event,
                                                          token: token!),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Details',
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                          color: Colors
                                              .white, // Text color over image
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
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        child: ListView.builder(
                                          itemCount: subEvents.length,
                                          itemBuilder: (context, subIndex) {
                                            final subEvent =
                                                subEvents[subIndex];
                                            final subName =
                                                subEvent.name ?? 'No Name';
                                            final subType =
                                                subEvent.type ?? 'No Type';
                                            final subStartDate = _formatDate(
                                                subEvent.startDate.toString());
                                            final subEndDate = _formatDate(
                                                subEvent.endDate.toString());
                                            final subCurrentParticipants =
                                                subEvent.currentParticipants
                                                    .toString();
                                            final subMaxParticipants = subEvent
                                                    .maxParticipants
                                                    .toString() ??
                                                'N/A';
                                            final subIsSubscribed =
                                                eventProvider.subscribedEventIds
                                                    .contains(subEvent.id);
                                            final subImagePath =
                                                subEvent.imagePath;

                                            return ExpansionTile(
                                              title: Text(
                                                subName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors
                                                      .white, // Text color over image
                                                ),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
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
                                                          Icons.calendar_today,
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
                                                      const SizedBox(
                                                          height: 10),
                                                      // Subscribe/Unsubscribe Button for Subevent
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Column(
                                                          children: [
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    subIsSubscribed
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .blue,
                                                              ),
                                                              onPressed:
                                                                  isSubscribed
                                                                      ? () {
                                                                          if (person != null &&
                                                                              token != null) {
                                                                            if (subIsSubscribed) {
                                                                              // Unsubscribe from subevent
                                                                              eventProvider.leaveEvent(context, subEvent.id).then((_) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('Unsubscribed from $subName'),
                                                                                  ),
                                                                                );
                                                                                setState(() {});
                                                                              }).catchError((error) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('Failed to unsubscribe: $error'),
                                                                                  ),
                                                                                );
                                                                              });
                                                                            } else {
                                                                              // Subscribe to subevent
                                                                              eventProvider.joinEvent(context, subEvent.id).then((_) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('Subscribed to $subName'),
                                                                                  ),
                                                                                );
                                                                                setState(() {});
                                                                              }).catchError((error) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('Failed to subscribe: $error'),
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
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                              onPressed: () {
                                                                // Navigate to the event details page
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => EventDetailsScreen(
                                                                        event:
                                                                            event,
                                                                        token:
                                                                            token!),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                'Details',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
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
        },
      ),
          ),
        ],
      ),
      drawer: DefaultDrawer(),
    );
    
  }

  /// Helper method to format date strings
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
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

