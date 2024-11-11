import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PersonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _people = [];
  List<dynamic> get events => _people;

  Future<void> loadEvents(String token) async {
    try {
      _people = await _apiService.fetchPeople(token);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }
}