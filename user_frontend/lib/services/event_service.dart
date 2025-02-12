import 'dart:convert';
import 'package:user_frontend/services/api_service.dart';

class EventService {
  static Future<List<dynamic>> fetchEvents() async {
    final response = await ApiService.get('/events/allandpastmain');
    if (response.statusCode == 200) {
      print("Got data: ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch event details');
    }
  }
}
