import 'dart:math';

import 'package:event_manager_flutter/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _events = [];
  List<dynamic> get events => _events;

  Set<int> _subscribedEventIds = {};
  Set<int> get subscribedEventIds => _subscribedEventIds;

  Future<void> loadEvents(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token!;
      _events = await _apiService.fetchEvents(token);
      notifyListeners();

      await loadSubscribedEvents(context);
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }

  Future<void> loadSubscribedEvents(BuildContext context) async {
    try {
      _subscribedEventIds.clear(); // Clear previous subscriptions


      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final personId = authProvider.currentPerson!['personId'];
      final token = authProvider.token!;

      _subscribedEventIds = await _apiService.getSubscribedEventIds(personId, token);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load subscribed events');
    }
  }

  Future<void> joinEvent(BuildContext context, int eventId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final personId = authProvider.currentPerson!['personId'];
      final token = authProvider.token!;

      await _apiService.joinEvent(eventId, personId, token);
      _subscribedEventIds.add(eventId);

      // Find the event and increment currentParticipants
      final eventIndex = _events.indexWhere((event) => event['id'] == eventId);
      if (eventIndex != -1) {
        _events[eventIndex]['currentParticipants'] =
          (_events[eventIndex]['currentParticipants'] ?? 0) + 1;
      }
      else
      {
        for (var event in _events) {
          if (event['subevents'] != null) {
            final subEventIndex = event['subevents'].indexWhere((subEvent) => subEvent['id'] == eventId);
            log(subEventIndex);
            if (subEventIndex != -1) {
              event['subevents'][subEventIndex]['currentParticipants'] =
                (event['subevents'][subEventIndex]['currentParticipants'] ?? 0) + 1;
              break;
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to join event: ${e.toString()}');
    }
  }

  Future<void> leaveEvent(BuildContext context, int eventId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final personId = authProvider.currentPerson!['personId'];
      final token = authProvider.token!;

      await _apiService.leaveEvent(eventId, personId, token);
      _subscribedEventIds.remove(eventId);

      // Find the event and decrement currentParticipants
      final eventIndex = _events.indexWhere((event) => event['id'] == eventId);
      if (eventIndex != -1) {
        _events[eventIndex]['currentParticipants'] =
            (_events[eventIndex]['currentParticipants'] ?? 1) - 1;
      }
      else
      {
        for (var event in _events) {
          if (event['subevents'] != null) {
            final subEventIndex = event['subevents'].indexWhere((subEvent) => subEvent['id'] == eventId);
            if (subEventIndex != -1) {
              event['subevents'][subEventIndex]['currentParticipants'] =
                  (event['subevents'][subEventIndex]['currentParticipants'] ?? 1) - 1;
              break;
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to leave event: ${e.toString()}');
    }
  }

  // New method to leave main event and all its sub-events
  Future<void> leaveMainEvent(BuildContext context, int mainEventId, List<dynamic> subEvents) async {
    try {
      

      // Unsubscribe from all sub-events
      for (var subEvent in subEvents) {
        if (_subscribedEventIds.contains(subEvent['id'])) {
          await leaveEvent(context, subEvent['id']);
        }
      }

      // Unsubscribe from main event
      await leaveEvent(context, mainEventId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unsubscribed from main event and all sub-events'),
        ),
      );
    } catch (e) {
      throw Exception('Failed to unsubscribe from main event and sub-events: $e');
    }
  }

  // EventProvider.dart
  void reset() {
    _events.clear();
    _subscribedEventIds.clear();
    notifyListeners();
  }
}