import 'package:flutter/material.dart';
import 'package:user_frontend/services/event_service.dart';
import 'package:user_frontend/widgets/event_widget.dart';
import 'package:user_frontend/widgets/text_filter.dart';

class EventsPage extends StatefulWidget {
  final bool onlyAccepted;
  final bool pastEvents;

  EventsPage({super.key, this.onlyAccepted = false, this.pastEvents = false});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<dynamic> _events = [];
  List<dynamic> _filteredEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndFilterEvents();
    print("Init state done");
  }

  Future<void> _fetchAndFilterEvents() async {
    try {
      print("Fetch and Filter Started");
      final eventsData = await EventService.fetchEvents();
      final events = eventsData;
      print("Got events: $events");

      final filteredEvents = events.where((event) {
        final eventDate = DateTime.parse(event['startDate']);
        print("Event date: $eventDate");
        final isPast = eventDate.isBefore(DateTime.now());
        print("Is past: $isPast");
        final isAccepted = event['status'] == 'accepted';
        print("Is accepted: $isAccepted");

        print("Past events: ${widget.pastEvents}");
        print("Only accepted: ${widget.onlyAccepted}");

        return (widget.pastEvents ? isPast : !isPast) &&
            (!widget.onlyAccepted || isAccepted);
      }).toList();

      setState(() {
        _events = filteredEvents;
        print("Events: $_events");
        _filteredEvents = filteredEvents;
        print("Filtered events: $_filteredEvents");
        _isLoading = false;
        print("Fetch and Filter Done");
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEventsByName(String query) {
    setState(() {
      print("Filtering events by name: $query");
      _filteredEvents = _events.where((event) {
        final name = (event['name'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.all(8.0),
                children: [
                  Text(
                    widget.pastEvents ? 'Past Events' : 'Upcoming Events',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_events.isNotEmpty)
                    TextFilter(
                      onTextChanged: _filterEventsByName,
                      hintText: 'Filter by name',
                    ),
                  if (_filteredEvents.isNotEmpty)
                    ..._filteredEvents.map(
                      (event) => EventWidget.fromMap(
                        event,
                        onlyView: widget.onlyAccepted || widget.pastEvents,
                      ),
                    ),
                ],
              ),
              if (_filteredEvents.isEmpty)
                Center(
                  child: Text(
                    _events.isEmpty
                        ? 'No events found'
                        : 'No events match your search',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
