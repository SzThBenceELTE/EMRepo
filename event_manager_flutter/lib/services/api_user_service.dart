import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiUserService {
  static const String _baseUrl = 'http://localhost:3000/api/users';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in');
    }
  }

  // Add other API methods as needed
}