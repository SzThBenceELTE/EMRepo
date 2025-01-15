// lib/screens/event_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/person_model.dart';
import '../providers/event_provider.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;
  final String token; // pass in the auth token if needed

  const EventDetailsScreen({Key? key, required this.event, required this.token})
      : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch subscribed users for the event
    _loadSubscribedUsers();
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

  String _dateFormater (DateTime date){
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute }';
  }

  @override
  Widget build(BuildContext context) {
    final subscribedUsers = Provider.of<EventProvider>(context)
        .getSubscribedUsersForEvent(widget.event.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name ?? 'Event Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display your event details (image, dates, etc.)
                        Text(
                          widget.event.name ?? 'No Name',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.event.type ?? 'No Type',
                          style: TextStyle(
                              fontSize: 16),
                        ),
                        Text(
                          'Start Date: ${_dateFormater(widget.event.startDate)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'End Date: ${_dateFormater(widget.event.endDate)}',
                          style: TextStyle(fontSize: 16),
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
                                physics: NeverScrollableScrollPhysics(),
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
                                        style:
                                            TextStyle(color: Colors.white),
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
