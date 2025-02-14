// lib/providers/person_provider.dart
import 'package:event_manager_flutter/services/real_time_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/person_model.dart';
import 'auth_provider.dart';

class PersonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;
  List<dynamic> _people = [];
  List<dynamic> get people => _people;  // (Consider renaming to "people" if that's what it holds)
  PersonModel? _currentPerson;
  PersonModel? get currentPerson => _currentPerson;

  PersonProvider({
    required RealTimeService realTimeService,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider {
    // When a refresh is received, use the token from the injected AuthProvider
    realTimeService.onRefresh((data) {
      print('PersonProvider received refresh event: $data');
      // Ensure the token is available before reloading
      final token = _authProvider.token;
      if (token != null) {
        loadPeople(token);
      } else {
        print('Cannot refresh people: token is null.');
      }
    });
  }
  
  Future<void> loadCurrentPerson(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser!.id;
      final token = authProvider.token;
      if (token != null) {
        _currentPerson = await _apiService.fetchPersonByUserId(userId, token);
        notifyListeners();
      } else {
        print('User ID or token is null');
      }
    } catch (e) {
      print('Failed to load current person: $e');
      // Handle error accordingly
    }
  }
  
  Future<void> loadPeople(String token) async {
    try {
      _people = await _apiService.fetchPeople(token);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load people');
    }
  }
}
