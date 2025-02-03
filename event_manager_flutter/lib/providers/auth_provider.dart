// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/login_response.dart';
import '../providers/person_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userData = prefs.getString('userData');
    if (userData != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  Future<void> login(String username, String password, BuildContext context) async {
    try {
      print('Logging in with $username and $password');
      LoginResponse response = await _apiService.login(username, password);
      print('Logged in: ${response.user}');
      _currentUser = response.user;
      _token = response.token;

      // Store token and user data securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));

      final personProvider = Provider.of<PersonProvider>(context, listen: false);
      await personProvider.loadCurrentPerson(context);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
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
      _currentUser = UserModel.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }
}