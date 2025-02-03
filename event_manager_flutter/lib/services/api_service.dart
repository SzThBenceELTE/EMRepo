import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person_model.dart'; // Ensure this model exists
import '../models/event_model.dart';
import '../models/login_response.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<LoginResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to login');
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

  Future<List<EventModel>> fetchEvents(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<EventModel>> fetchAllEvents(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/allandpastmain'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
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

  // api_service.dart


  Future<void> joinEvent(int eventId, int personId, String token) async {
    final url = Uri.parse('$_baseUrl/events/join');
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
      print('Failed to join event: ${response.body}');
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
      print('Failed to leave event: ${response.body}');
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

Future<PersonModel> fetchPersonByUserId(int userId, String token) async {
    final url = Uri.parse('$_baseUrl/users/$userId/person');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      //print(jsonDecode(response.body));
      return PersonModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch person');
    }
  }

  Future<Set<int>> fetchSubscribedEventIds(int personId, String token) async {
    final url = Uri.parse('$_baseUrl/people/$personId/subscribed-events');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final data = jsonDecode(response.body);
      List<dynamic> ids = data['subscribedEventIds'];
      return ids.map((id) => id as int).toSet();
    } else {
      throw Exception('Failed to fetch subscribed event IDs');
    }
  }
  
   /// Fetches the list of subscribed users for a given event.
  Future<List<PersonModel>> fetchSubscribedUsers({
    required int eventId,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/events/$eventId/subscribedUsers');
    
    
    // Send request with proper headers including authentication token.
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // if you use Bearer tokens
      },
    );

    if (response.statusCode == 200) {
      // Parse the response into a list.
      final data = jsonDecode(response.body);
      // Here, we assume the response looks like: { subscribedUsers: [ {...}, {...}, ... ] }
      final List<dynamic> usersJson = data['subscribedUsers'];
      
      // Map each JSON object to a PersonModel instance.
      return usersJson
          .map((json) => PersonModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load subscribed users');
    }
  }

  Future<List<EventModel>> getSubscribedEventsForPerson({
    required int personId,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/events/$personId/subscribedEvents');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> eventsJson = data['subscribedEvents'];
      return eventsJson.map((json) => EventModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch subscribed events for personId $personId');
    }
  }

  // Add other API methods as needed
}