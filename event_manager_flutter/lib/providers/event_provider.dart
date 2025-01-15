// lib/providers/event_provider.dart

import 'package:event_manager_flutter/models/person_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'person_provider.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EventModel> _events = [];
  Set<int> _subscribedEventIds = {};
  final Map<int, List<PersonModel>> _subscribedUsersCache = {};

  List<EventModel> get events => _events;
  Set<int> get subscribedEventIds => _subscribedEventIds;


  void setEvents(List<EventModel> events) {
    _events = events;
    notifyListeners();
  }

  Future<List<EventModel>> fetchEvents(String token) async {
    try {
      List<EventModel> data = await ApiService().fetchEvents(token);
      //print('Fetched Events: $data'); // Optional: For debugging
      return data; // Directly return the mapped EventModel instances
    } catch (error) {
      print('Error in EventProvider.fetchEvents: $error');
      throw Exception('Failed to load events: $error');
    }
  }

  void reset() {
    _events = [];
    _subscribedEventIds = {};
    notifyListeners();
  }

    Future<void> joinEvent(BuildContext context, int eventId) async {
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final personId = personProvider.currentPerson?.id;
    final token = authProvider.token;

    print('Token: $token');
    print('Person ID: $personId');

    if (personId != null && token != null) {
      try {
        // Make API call to join the event
        await _apiService.joinEvent(eventId, personId, token);
        // Update the subscribed events
        _subscribedEventIds.add(eventId);
        // Update currentParticipants in the event model
        _updateEventParticipantCount(eventId, increment: true);
        notifyListeners();
      } catch (e) {
        print('Error joining event: $e');
        throw e;
      }
    } else {
      print('Person ID or token is null');
      throw Exception('Authentication required');
    }
  }

  Future<void> leaveEvent(BuildContext context, int eventId) async {
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final personId = personProvider.currentPerson?.id;
    final token = authProvider.token;

    print('Person ID: $personId');
    print('Token: $token');
    
    

    if (personId != null && token != null) {
      try {
        // Make API call to leave the event
        await _apiService.leaveEvent(eventId, personId, token);
        // Update the subscribed events
        _subscribedEventIds.remove(eventId);
        // Update currentParticipants in the event model
        _updateEventParticipantCount(eventId, increment: false);
        notifyListeners();
      } catch (e) {
        print('Error leaving event: $e');
        throw e;
      }
    } else {
      print('Person ID or token is null');
      throw Exception('Authentication required');
    }
  }


  Future<void> leaveMainEvent(BuildContext context, int eventId, List<EventModel> subEvents) async {
  final personProvider = Provider.of<PersonProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final personId = personProvider.currentPerson?.id;
  final token = authProvider.token;

  print('Token: $token');
  print('Person ID: $personId');

  if (personId != null && token != null) {
    try {
      // Check and leave only subscribed subevents
      for (var subEvent in subEvents) {
        if (_subscribedEventIds.contains(subEvent.id)) {
          await leaveEvent(context, subEvent.id);
          _subscribedEventIds.remove(subEvent.id);
          print('Left subevent: ${subEvent.id}');
        } else {
          print('Not subscribed to subevent: ${subEvent.id}, skipping.');
        }
      }

      // Leave the main event
      await _apiService.leaveEvent(eventId, personId, token);
      _subscribedEventIds.remove(eventId);
      // Update currentParticipants in the event model
      _updateEventParticipantCount(eventId, increment: false);

      notifyListeners();
      print('Successfully left the main event.');
    } catch (e) {
      print('Error leaving main event and subevents: $e');
      throw e;
    }
  } else {
    print('Person ID or token is null');
    throw Exception('Authentication required');
  }
}

  /// Loads events by fetching them from the API and setting them in the provider.
  Future<void> loadEvents(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      // Handle the case where the token is not available
      throw Exception('Authentication token not found.');
    }

    try {
      final fetchedEvents = await fetchEvents(token);
      setEvents(fetchedEvents);
    } catch (error) {
      // Handle errors accordingly
      throw Exception('Failed to load events: $error');
    }
  }

  void _updateEventParticipantCount(int eventId, {required bool increment}) {
    void updateCount(List<EventModel> events) {
      for (var event in events) {
        if (event.id == eventId) {
          if (increment) {
            event.currentParticipants += 1;
          } else {
            event.currentParticipants = (event.currentParticipants > 0)
                ? event.currentParticipants - 1
                : 0;
          }
          break;
        }
        // Recursively update subevents
        if (event.subevents.isNotEmpty) {
          updateCount(event.subevents);
        }
      }
    }

    updateCount(_events);
  }

  

  Future<void> fetchSubscribedEventIds(BuildContext context) async {
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final personId = personProvider.currentPerson?.id;
    final token = authProvider.token;

    if (personId != null && token != null) {
      try {
        final ids = await _apiService.fetchSubscribedEventIds(personId, token);
        print('subscribe event ids: $ids');
        _subscribedEventIds = ids;
        notifyListeners();
      } catch (e) {
        print('Error fetching subscribed event IDs: $e');
        throw e;
      }
    }
  }

  List<PersonModel> getSubscribedUsersForEvent(int eventId) {
    return _subscribedUsersCache[eventId] ?? [];
  }

  /// Fetch and store subscribed users for an event
  Future<void> fetchSubscribedUsers({
    required int eventId,
    required String token,
  }) async {
    try {
      final users = await _apiService.fetchSubscribedUsers(
        eventId: eventId,
        token: token,
      );
      _subscribedUsersCache[eventId] = users;
      notifyListeners();
    } catch (error) {
      throw Exception('Error fetching subscribed users: $error');
    }
  }
  
}