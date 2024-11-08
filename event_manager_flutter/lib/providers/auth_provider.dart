// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  String? get token => _token;

  Future<void> login(String username, String password) async {
    try {
      _token = await _apiService.login(username, password);
      // Optionally, store token securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      notifyListeners();
    } catch (e) {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}