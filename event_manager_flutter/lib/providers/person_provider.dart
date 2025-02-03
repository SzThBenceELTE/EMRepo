import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/person_model.dart';
import 'auth_provider.dart';

class PersonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _people = [];
  List<dynamic> get events => _people;
  PersonModel? _currentPerson;
  PersonModel? get currentPerson => _currentPerson;
  


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
  

  Future<void> loadEvents(String token) async {
    try {
      _people = await _apiService.fetchPeople(token);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }
}