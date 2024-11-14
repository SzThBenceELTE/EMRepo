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
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to leave event: ${e.toString()}');
    }
  }

  // EventProvider.dart
  void reset() {
    _events.clear();
    _subscribedEventIds.clear();
    notifyListeners();
  }
}