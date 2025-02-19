import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user_frontend/services/api_service.dart';
import 'package:user_frontend/services/auth_service.dart';

class EventWidget extends StatefulWidget {
  final int eventId, limit, rank;
  final bool onlyView, asPage;
  final String name,
      description,
      date,
      startTime,
      endTime,
      location,
      image,
      status,
      subevent_name,
      subevent_description,
      subevent_startTime,
      subevent_endTime,
      subevent_location,
      subevent_limit,
      subevent_status;

  final void Function() onStatusChanged;

  EventWidget({
    required this.eventId,
    required this.name,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.limit,
    required this.image,
    required this.status,
    required this.subevent_name,
    required this.subevent_description,
    required this.subevent_startTime,
    required this.subevent_endTime,
    required this.subevent_location,
    required this.subevent_limit,
    required this.subevent_status,
    required this.onStatusChanged,
    required this.rank,
    required this.onlyView,
    required this.asPage,
  });

  EventWidget.fromMap(Map<String, dynamic> event,
      {this.onlyView = false,
      this.asPage = false,
      this.onStatusChanged = _defaultOnStatusChanged})
      : eventId = event['id'],
        name = event['name'],
        description = event['description'] ?? '',
        date = event['startDate'] ?? '',
        startTime = event['startDate'] ?? '',
        endTime = event['endDate'] ?? '',
        location = event['location'] ?? '',
        limit = event['maxParticipants'] ?? 0,
        image = "http://localhost:3000/" + (event['imagePath'] ?? "uploads/default/image3-min-1.webp"),
        status = event['status'] ?? 'pending',
        subevent_name = event['subevent_name'] ?? '',
        subevent_description = event['subevent_description'] ?? '',
        subevent_startTime = event['subevent_startTime'] ?? '',
        subevent_endTime = event['subevent_endTime'] ?? '',
        subevent_location = event['subevent_location'] ?? '',
        subevent_limit = event['subevent_limit']?.toString() ?? '',
        subevent_status = event['subevent_status'] ?? 'pending',
        rank = event['rank'] ?? 0;

  static void _defaultOnStatusChanged() {}

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  late String status;
  late String subeventStatus;
  late int waitingListPosition;
  late int subeventWaitingListPosition;
  late bool isParticipant;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializer();
  }

  void _initializer() async {
    isParticipant = await _isParticipant();
    print("IsParticipant: $isParticipant");
    status = isParticipant ? 'accepted' : 'rejected';
    subeventStatus = widget.subevent_status;
    waitingListPosition = status == 'accepted' ? 0 : widget.rank;
    subeventWaitingListPosition =
        subeventStatus == 'accepted' ? 0 : widget.rank;
    print("Event: ${widget.name}");
    print("Status: $status");
    setState(() {
      _isInitialized = true;
    });
  }

  Future<bool> _isParticipant() async {
    print("Calling _isParticipant");
    var person = await AuthService.getPerson();
    if (person == null) {
      return false;
    }
    var personId = person['id'];
    print("Person ID: $personId");
    print("Event ID: ${widget.eventId}");
    var response =
        await ApiService.get('/events/${widget.eventId}/subscribedUsers');
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      for (var user in body['subscribedUsers']) {
        if (user['id'] == personId) {
          print("User is participant");
          return true;
        }
      }
    }
    print("User is not participant");
    return false;
  }

  bool _isParticipantSimple() {
    return status == 'accepted';
  }

  void _updateStatus(String newStatus, {bool isSubevent = false}) async {
    var response = await ApiService.patch(
        '/events/${widget.eventId}/change-status', {
      'status': newStatus,
      'subevent': isSubevent,
    });
    if (response.statusCode == 201) {
      var body = jsonDecode(response.body);
      setState(() {
        if (isSubevent) {
          subeventStatus = body['status'];
          subeventWaitingListPosition = body['rank'] ?? 0;
        } else {
          status = body['status'];
          waitingListPosition = body['rank'] ?? 0;
          if (status == 'rejected') {
            subeventStatus = 'pending';
          }
        }
      });
      widget.onStatusChanged();
    }
  }

  void _joinEvent() async {
    var person = await AuthService.getPerson();
    if (person == null) {
      return;
    }
    var personId = person['id'];
    var response = await ApiService.post('/events/join', {
      'eventId': widget.eventId,
      'personId': personId,
    });
    if (response.statusCode == 200) {
      setState(() {
        status = "accepted";
      });
      //widget.onStatusChanged();
    }
  }

  void _leaveEvent() async {
    var person = await AuthService.getPerson();
    if (person == null) {
      return;
    }
    var personId = person['id'];
    var response = await ApiService.post('/events/leave', {
      'eventId': widget.eventId,
      'personId': personId,
    });
    if (response.statusCode == 200) {
      setState(() {
        status = "rejected";
      });
      //widget.onStatusChanged();
    }
  }

  Widget _buildStatusButton(
      String text, VoidCallback? onPressed, Color backgroundColor) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[parsedDate.month - 1]} ${parsedDate.day}';
  }

  String _formatTime(String time) {
    DateTime parsedTime = DateTime.parse(time);
    return '${parsedTime.hour}:${parsedTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    if (widget.asPage) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              SizedBox(height: 10.0),
              Center(
                child: Text(
                  widget.name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${widget.date.substring(0, 4)} ${_formatDate(widget.date)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                      Image.network(widget.image,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.location, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Limit: ${widget.limit.toString()}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10.0),
              Text(widget.description),
              SizedBox(height: 10.0),
              if (widget.subevent_name != '') ...[
                SizedBox(height: 5.0),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                SizedBox(height: 5.0),
                Center(
                  child: Text(
                    widget.subevent_name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Text('${widget.subevent_startTime} - ${widget.subevent_endTime}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.location, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Limit: ${widget.limit.toString()}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventWidget(
                eventId: widget.eventId,
                name: widget.name,
                description: widget.description,
                date: widget.date,
                startTime: widget.startTime,
                endTime: widget.endTime,
                location: widget.location,
                limit: widget.limit,
                image: widget.image,
                status: widget.status,
                subevent_name: widget.subevent_name,
                subevent_description: widget.subevent_description,
                subevent_startTime: widget.subevent_startTime,
                subevent_endTime: widget.subevent_endTime,
                subevent_location: widget.subevent_location,
                subevent_limit: widget.subevent_limit,
                subevent_status: widget.subevent_status,
                rank: widget.rank,
                onlyView: widget.onlyView,
                asPage: true,
                onStatusChanged: widget.onStatusChanged,
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10.0),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}'),
                    Text(_formatDate(widget.date)),
                    SizedBox(height: 10.0),
                      Image.network(widget.image,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,),
                  ],
                ),
                SizedBox(height: 10.0),
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatusButton(
                        status == 'accepted' ? 'Leave' : 'Join',
                        (_isParticipantSimple())
                            ? () => _leaveEvent()
                            : () => _joinEvent(),
                        (_isParticipantSimple()) ? Colors.red : Colors.green,
                      ),
                      
                    ],
                    
                  ),
                
              ],
            ),
          ),
        ),
      );
    }
  }
}
