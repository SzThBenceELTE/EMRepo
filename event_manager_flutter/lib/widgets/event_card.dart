// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import '../models/event_model.dart';

typedef EventCallback = Future<void> Function(EventModel event);

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isSubscribed;
  final EventCallback onSubscribe;
  final EventCallback onUnsubscribe;
  final VoidCallback? onRefresh; // Optional callback to refresh after actions

  // You can customize these properties or add more parameters as needed.
  const EventCard({
    Key? key,
    required this.event,
    required this.isSubscribed,
    required this.onSubscribe,
    required this.onUnsubscribe,
    this.onRefresh,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract event data for readability
    final String name = event.name ?? 'No Name';
    final String type = event.type ?? 'No Type';
    final String startDate = _formatDate(event.startDate.toString());
    final String endDate = _formatDate(event.endDate.toString());
    final String currentParticipants = event.currentParticipants.toString();
    final String maxParticipants = event.maxParticipants.toString();
    final List subEvents = event.subevents ?? [];
    final String? imagePath = event.imagePath;

    return Card(
      color: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(10),
          image: imagePath != null && imagePath.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // You can log the error or show a fallback image.
                  },
                )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.65),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Main Event Info
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Event title and details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white30,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildEventDetailRow(Icons.category, type),
                        _buildEventDetailRow(Icons.calendar_today, 'Start: $startDate'),
                        _buildEventDetailRow(Icons.calendar_today_outlined, 'End: $endDate'),
                        _buildEventDetailRow(
                          Icons.people,
                          'Participants: $currentParticipants / $maxParticipants',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Subscribe/Unsubscribe button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubscribed ? Colors.red : Colors.blue,
                        ),
                        onPressed: () async {
                          if (isSubscribed) {
                            await onUnsubscribe(event);
                          } else {
                            await onSubscribe(event);
                          }
                          if (onRefresh != null) {
                            onRefresh!();
                          }
                        },
                        child: Text(
                          isSubscribed ? 'Unsubscribe' : 'Subscribe',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right Column: Subevents (if any)
              if (subEvents.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subevents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: ListView.builder(
                          itemCount: subEvents.length,
                          itemBuilder: (context, subIndex) {
                            final subEvent = subEvents[subIndex];
                            final subName = subEvent.name ?? 'No Name';
                            final subType = subEvent.type ?? 'No Type';
                            final subStartDate = _formatDate(subEvent.startDate.toString());
                            final subEndDate = _formatDate(subEvent.endDate.toString());
                            final subCurrentParticipants = subEvent.currentParticipants.toString();
                            final subMaxParticipants = subEvent.maxParticipants.toString();
                            // For subevents, you might want to have separate callbacks;
                            // for simplicity, here we call the same ones as for main events.
                            final bool subIsSubscribed = false; // Modify accordingly

                            return ExpansionTile(
                              title: Text(
                                subName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildEventDetailRow(Icons.category, subType),
                                      _buildEventDetailRow(Icons.calendar_today, 'Start: $subStartDate'),
                                      _buildEventDetailRow(Icons.calendar_today_outlined, 'End: $subEndDate'),
                                      _buildEventDetailRow(
                                        Icons.people,
                                        'Participants: $subCurrentParticipants / $subMaxParticipants',
                                      ),
                                      const SizedBox(height: 10),
                                      // Subevent subscribe/unsubscribe button (optional)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: subIsSubscribed ? Colors.red : Colors.blue,
                                          ),
                                          onPressed: subIsSubscribed
                                              ? null
                                              : () {
                                                  // Implement subevent subscribe/unsubscribe if needed.
                                                },
                                          child: Text(
                                            subIsSubscribed ? 'Unsubscribe' : 'Subscribe',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
