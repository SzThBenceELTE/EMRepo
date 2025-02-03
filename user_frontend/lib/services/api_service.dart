import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_frontend/services/auth_service.dart';

class ApiService {
  static final String baseUrl = 'http://localhost:3000';

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response;
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }
}
