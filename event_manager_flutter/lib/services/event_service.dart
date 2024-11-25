// lib/services/event_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class EventService {
  final String apiUrl = 'http://localhost:3000/api/events';

  Future<List<EventModel>> fetchEvents() async {
    final response = await http.get(Uri.parse(apiUrl));
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Data: $data');
      return data.map((json) => EventModel.fromJson(json)).toList();
    } else {
      print("Something is wrong with the map in fetchEvents");
      throw Exception('Failed to load events');
    }
  }
}