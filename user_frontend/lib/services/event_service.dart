import 'dart:convert';
import 'package:user_frontend/services/api_service.dart';

class EventService {
  static Future<Map<String, dynamic>> fetchEvents() async {
    final response = await ApiService.get('/events/my-events');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch event details');
    }
  }
}
