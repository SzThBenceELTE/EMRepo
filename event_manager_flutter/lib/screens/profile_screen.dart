// lib/screens/profile_screen.dart

import 'package:event_manager_flutter/screens/eventDetails_screen.dart';
import 'package:event_manager_flutter/widgets/default_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/person_model.dart';
import '../providers/auth_provider.dart';
import '../providers/person_provider.dart';
import '../services/api_service.dart';
import 'package:event_manager_flutter/services/real_time_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  PersonModel? _currentPerson;
  
  // Full list of subscribed events from the server
  List<EventModel> _allSubscribedEvents = [];
  // This list will hold the filtered events based on the "upcoming" checkbox.
  List<EventModel> _filteredSubscribedEvents = [];
  
  // Controls whether only upcoming events are shown.
  bool _onlyShowUpcoming = false;
  
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    
    // Subscribe to refresh events from the RealTimeService.
    // This ensures that whenever a refresh event is emitted from the server,
    // we reload the profile data.
    final realTimeService = Provider.of<RealTimeService>(context, listen: false);
    realTimeService.onRefresh((data) {
      print('ProfileScreen received refresh event: $data');
      _loadProfileData();
    });
  }
  
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('Loading profile data');
      
      // Load current person from PersonProvider.
      final personProvider = Provider.of<PersonProvider>(context, listen: false);
      await personProvider.loadCurrentPerson(context);
      _currentPerson = personProvider.currentPerson;
      
      // Retrieve auth token from AuthProvider.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (_currentPerson == null || token == null) {
        throw Exception('No user data found.');
      }
      
      // Use the ApiService to get full subscribed event details for the person.
      // Adjust the endpoint as necessary.
      final events = await _apiService.getSubscribedEventsForPerson(
        personId: _currentPerson!.id,
        token: token,
      );
      
      setState(() {
        _allSubscribedEvents = events;
        // Initially, display the full list.
        _filteredSubscribedEvents = List.from(events);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load profile: $error';
        _isLoading = false;
      });
      print('Error loading profile: $error');
    }
  }
  
  /// Filters the subscribed events based on whether they are upcoming.
  void _applyUpcomingFilter() {
    final now = DateTime.now();
    setState(() {
      if (_onlyShowUpcoming) {
        _filteredSubscribedEvents = _allSubscribedEvents.where((event) {
          final eventEndDate = DateTime.parse(event.endDate.toString());
          return eventEndDate.isAfter(now);
        }).toList();
      } else {
        _filteredSubscribedEvents = List.from(_allSubscribedEvents);
      }
    });
  }
  
  /// A helper function to format a date.
  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      drawer: const DefaultDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the current user's name.
                      Text(
                        'Hello, ${_currentPerson?.firstName ?? ''} ${_currentPerson?.surname ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display the number of subscribed events.
                      Text(
                        'You are subscribed to ${_allSubscribedEvents.length} event(s).',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(height: 32),
                      // Filtering Checkbox Row.
                      Row(
                        children: [
                          Checkbox(
                            value: _onlyShowUpcoming,
                            onChanged: (value) {
                              setState(() {
                                _onlyShowUpcoming = value ?? false;
                              });
                              _applyUpcomingFilter();
                            },
                          ),
                          const Text('Only show upcoming events'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Subscribed Events:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display the list of subscribed events.
                      Expanded(
                        child: _filteredSubscribedEvents.isEmpty
                            ? const Center(child: Text('You have no subscribed events.'))
                            : ListView.separated(
                                itemCount: _filteredSubscribedEvents.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final event = _filteredSubscribedEvents[index];
                                  return ListTile(
                                    title: Text(event.name ?? 'No Name'),
                                    subtitle: Text(
                                      'Type: ${event.type ?? ''}\n'
                                      'Start: ${_formatDate(event.startDate.toString())}',
                                    ),
                                    isThreeLine: true,
                                    trailing: const Icon(Icons.keyboard_arrow_right),
                                    onTap: () {
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventDetailsScreen(
                                              event: event,
                                              token: authProvider.token!),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
