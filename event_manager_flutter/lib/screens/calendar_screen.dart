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
import '../utils/card_builder.dart'; // Import the CardBuilder

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

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
    _events = {};



    // final events = Provider.of<EventProvider>(context, listen: false).allEvents;
    //   _events = {};
    //   for (var event in events) {
    //     DateTime eventDate = DateTime(
    //       event.startDate.year,
    //       event.startDate.month,
    //       event.startDate.day,
    //     );
    //     if (_events[eventDate] == null) {
    //       _events[eventDate] = [event];
    //     } else {
    //       _events[eventDate]!.add(event);
    //     }
    //   }


    _loadPersonAndEvents();

  }

  Future<void> _loadPersonAndEvents() async {
    try {
      print('loading events and filtering');

      final personProvider =
          Provider.of<PersonProvider>(context, listen: false);
      await personProvider.loadCurrentPerson(context);
      print('loaded current person');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final token = authProvider.token;

      if (currentUser == null || token == null) {
        throw Exception('No user data found.');
      }
      print('got current user');

      final apiService = ApiService();
      _currentPerson = await apiService.fetchPersonByUserId(
          currentUser.id, authProvider.token!);


      // Fetch subscribed event IDs after loading current person
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.fetchSubscribedEventIds(context);
      print('Fetched subscribed event IDs');

      

      // Fetch the associated Person

      final events = Provider.of<EventProvider>(context, listen: false).allEvents;
      
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

  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
  final Map<DateTime, List<EventModel>> grouped = {};
  for (var event in events) {
    // Normalize the date (remove time)
    final date = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
    if (grouped.containsKey(date)) {
      grouped[date]!.add(event);
    } else {
      grouped[date] = [event];
    }
  }
  return grouped;
}
  

  @override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final token = authProvider.token;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Calendar'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<EventProvider>(
            builder: (context, eventProvider, child) {
              // Group the events from the provider
              final eventsMap = _groupEventsByDate(eventProvider.allEvents);

              // Get events for selected day
              final eventsForSelectedDay = eventsMap[DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                  )] ??
                  [];

              return Column(
                children: [
                  TableCalendar<EventModel>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    // Use the computed eventsMap
                    eventLoader: (day) {
                      return eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
                    },
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
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                    ),
                    calendarStyle: const CalendarStyle(
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
                        if (events.isEmpty) return const SizedBox();
                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: events.map((event) {
                              final isPast = event.startDate.isBefore(DateTime.now());
                              final isSubscribed = eventProvider.subscribedEventIds.contains(event.id);
                              final dotColor = isSubscribed
                                  ? Colors.green
                                  : isPast
                                      ? Colors.red
                                      : Colors.lightBlue;
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
                  // If there are no events for the selected day, show a message
                  Expanded(
                    child: eventsForSelectedDay.isEmpty
                        ? const Center(child: Text('No events for this day'))
                        : ListView.builder(
                            itemCount: eventsForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final event = eventsForSelectedDay[index];
                              final name = event.name ?? 'No Name';
                              final type = event.type ?? 'No Type';
                              final startDate = _formatDate(event.startDate.toString());
                              final endDate = _formatDate(event.endDate.toString());
                              final currentParticipants = event.currentParticipants.toString();
                              final maxParticipants = event.maxParticipants.toString();
                              final isSubscribed = eventProvider.subscribedEventIds.contains(event.id);
                              final subEvents = event.subevents ?? [];
                              final imagePath = event.imagePath;
                              print('Event ID: ${event.id}, Name: $name, Image: $imagePath');
                              return event.startDate.isBefore(DateTime.now())
                                  ? CardBuilder.createOldCard(
                                      context: context,
                                      eventProvider: eventProvider,
                                      person: _currentPerson,
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
                                    )
                                  : CardBuilder.createCard(
                                      context: context,
                                      eventProvider: eventProvider,
                                      person: _currentPerson,
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
              );
            },
          ),
    drawer: const DefaultDrawer(),
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


}

