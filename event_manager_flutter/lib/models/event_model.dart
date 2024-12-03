// lib/models/event.model.dart

class EventModel {
  final int id;
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  int currentParticipants;
  List<EventModel> subevents;
  final List<String> groups;

  EventModel({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.currentParticipants,
    this.subevents = const [],
    required this.groups,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? subeventsFromJson = json['subevents'];
    List<EventModel> subeventsList = subeventsFromJson != null
        ? subeventsFromJson.map((i) => EventModel.fromJson(i)).toList()
        : [];

    List<String> groupsList = [];
    if (json['groups'] != null && json['groups'] is List) {
      groupsList = List<String>.from(json['groups'].map((group) => group.toString()));
    }

    return EventModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      subevents: subeventsList,
      groups: groupsList,
    );
  }
}