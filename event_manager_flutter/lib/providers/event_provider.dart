import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _events = [];
  List<dynamic> get events => _events;

  Future<void> loadEvents(String token) async {
    try {
      _events = await _apiService.fetchEvents(token);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }
}