// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  Map<String, dynamic>? _currentPerson;

  
  String? get token => _token;
  Map<String, dynamic>? get currentPerson => _currentPerson;
  

  Future<void> login(String username, String password) async {
    try {
      // Obtain the JWT token
      _token = await _apiService.login(username, password);
      
      // Debugging: Print the received token
      print('Token received: $_token');
      
      // Store the token securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      // Fetch current user data using the token
      _currentPerson = await _apiService.getCurrentUser(_token!);

      // Debugging: Print the fetched user data
      print('Current Person: $_currentPerson');

      // Store user data securely
      await prefs.setString('currentUser', jsonEncode(_currentPerson!));

      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentPerson = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('currentUser');
    notifyListeners();
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userData = prefs.getString('currentUser');
    if (_token != null && userData != null) {
      _currentPerson = jsonDecode(userData);
      notifyListeners();
    }
  }
}