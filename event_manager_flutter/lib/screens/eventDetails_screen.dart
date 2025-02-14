// lib/screens/event_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/person_model.dart';
import '../providers/event_provider.dart';

import '../services/real_time_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;
  final String token; // pass in the auth token if needed

  EventDetailsScreen({super.key, required this.event, required this.token}){
    print("EventDetailsScreen constructor");
    print (this.event.name);
  }

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  // Store the refresh callback so we can remove it on dispose.
  late void Function(dynamic) _refreshCallback;

@override
void initState() {
  super.initState();
  print("Initial event name from widget: ${widget.event.name}");
  final eventProvider = Provider.of<EventProvider>(context, listen: false);
  final updatedEvent = eventProvider.allEvents.firstWhere(
    (event) => event.id == widget.event.id,
    orElse: () => widget.event,
  );
  print("Updated event name from provider: ${updatedEvent.name}");
  _loadSubscribedUsers();
  
  _refreshCallback = (data) {
    print('EventDetailsScreen received refresh event: $data');
    _loadSubscribedUsers();
  };
  final realTimeService = Provider.of<RealTimeService>(context, listen: false);
  realTimeService.onRefresh(_refreshCallback);
}

  @override
  void dispose() {
    // Remove the refresh event listener when the widget is disposed.
    final realTimeService = Provider.of<RealTimeService>(context, listen: false);
    realTimeService.getSocket().off('refresh', _refreshCallback);
    super.dispose();
  }

  Future<void> _loadSubscribedUsers() async {
    try {
      await Provider.of<EventProvider>(context, listen: false)
          .fetchSubscribedUsers(eventId: widget.event.id, token: widget.token);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  String _dateFormater(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    final EventProvider eventProvider = Provider.of<EventProvider>(context);
    final updatedEvent = eventProvider.allEvents.firstWhere((event) => event.id == widget.event.id,
                                                                          orElse: () => widget.event,);
    
    print("Updated Event: ");
    print(updatedEvent.name);
    print(updatedEvent.type);
    print(updatedEvent.startDate);
    print(updatedEvent.endDate);
    final subscribedUsers = Provider.of<EventProvider>(context)
        .getSubscribedUsersForEvent(updatedEvent.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedEvent.name ?? 'Event Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display event details
                        Text(
                          updatedEvent.name ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          updatedEvent.type ?? 'No Type',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Start Date: ${_dateFormater(updatedEvent.startDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'End Date: ${_dateFormater(updatedEvent.endDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Already Attending:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        subscribedUsers.isEmpty
                            ? const Text('No subscriptions yet.')
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: subscribedUsers.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  final PersonModel user =
                                      subscribedUsers[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        user.firstName.substring(0, 1),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                        '${user.firstName} ${user.surname}'),
                                    subtitle: Text(
                                        'Role: ${user.role.toString().split('.').last}'),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
