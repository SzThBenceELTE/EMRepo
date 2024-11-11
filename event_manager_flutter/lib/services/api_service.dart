import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
       log('Login successful, token: ${data['loginToken']}');
      return data['loginToken']; // Return the JWT token
    } else {
      throw Exception('Failed to log in');
    }
  }

  // Example of making an authenticated request
  Future<void> getProtectedData(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/protected'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Handle data
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<dynamic>> fetchEvents(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<dynamic>> fetchPeople(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/people'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load people');
    }
  }

  // Add other API methods as needed
}