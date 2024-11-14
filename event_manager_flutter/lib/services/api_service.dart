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

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user data');
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

  Future<void> joinEvent(int eventId, int personId, String token) async {
    final url = Uri.parse('$_baseUrl/events/join');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // If you're using JWT
      },
      body: jsonEncode({
        'eventId': eventId,
        'personId': personId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to join event');
    }
  }

  Future<void> leaveEvent(int eventId, int personId, String token) async {
    final url = Uri.parse('$_baseUrl/events/leave');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventId': eventId,
        'personId': personId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to leave event');
    }
  }

  // Optional: Fetch subscription status
  Future<bool> isSubscribed(int eventId, int personId, String token) async {
    final url = Uri.parse('$_baseUrl/events/$eventId/isSubscribed/$personId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['subscribed'] as bool;
    } else {
      throw Exception('Failed to fetch subscription status');
    }
  }

  Future<Set<int>> getSubscribedEventIds(int personId, String token) async {
  final url = Uri.parse('$_baseUrl/users/$personId/subscribedEvents');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> ids = data['subscribedEventIds'];
    return ids.map((id) => id as int).toSet();
  } else {
    throw Exception('Failed to fetch subscribed event IDs');
  }
}

  // Add other API methods as needed
}