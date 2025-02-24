import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user_frontend/services/api_service.dart';
import 'package:user_frontend/services/auth_service.dart';

class Subevent {
  final int id;
  final String name;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final int limit;
  String status;

  Subevent({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.limit,
    required this.status,
  });

  factory Subevent.fromMap(Map<String, dynamic> map) {
    return Subevent(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      startTime: map['startDate'] ?? '',
      endTime: map['endDate'] ?? '',
      location: map['location'] ?? '',
      limit: map['maxParticipants'] ?? 0,
      status: map['status'] ?? 'pending',
    );
  }
}


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
      status;


  final List<Subevent> subevents;
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
    required this.subevents,
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
        rank = event['rank'] ?? 0,
        subevents = (event['subevents'] as List<dynamic>?)
            ?.map((se) => Subevent.fromMap(se))
            .toList() ?? [];

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
  // Check if the current user is a participant.
  isParticipant = await _isParticipant();
  print("IsParticipant: $isParticipant");
  
  // Set the main event status.
  status = isParticipant ? 'accepted' : 'rejected';
  
  // For subevent status, use the first subevent if available, otherwise default to 'pending'.
  subeventStatus = widget.subevents.isNotEmpty ? widget.subevents.first.status : 'pending';
  
  // Compute waiting list positions.
  waitingListPosition = (status == 'accepted') ? 0 : widget.rank;
  subeventWaitingListPosition = (subeventStatus == 'accepted') ? 0 : widget.rank;
  
  print("Event: ${widget.name}");
  print("Status: $status");
  
  // Once initialization is complete, update the UI.
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

  bool _isParticipantSubevent(Subevent subevent) {
    return subevent.status == 'accepted';
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

  Future<void> _joinSubEvent(Subevent subevent) async {
    var person = await AuthService.getPerson();
    if (person == null) {
      return;
    }
    var personId = person['id'];
    var response = await ApiService.post('/events/join', {
      'eventId': subevent.id,
      'personId': personId,
    });
    if (response.statusCode == 200) {
      setState(() {
        subevent.status = "accepted";
      });
      //widget.onStatusChanged();
    }
  }

  Future<void> _leaveSubEvent(Subevent subevent) async {
    var person = await AuthService.getPerson();
    if (person == null) {
      return;
    }
    var personId = person['id'];
    var response = await ApiService.post('/events/leave', {
      'eventId': subevent.id,
      'personId': personId,
    });
    if (response.statusCode == 200) {
      setState(() {
        subevent.status = "rejected";
      });
      //widget.onStatusChanged();
    }
  }

  Future<void> _joinEvent() async {
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

  Future<void> _leaveEvent() async {
  var person = await AuthService.getPerson();
  if (person == null) return;
  var personId = person['id'];
  var response = await ApiService.post('/events/leave', {
    'eventId': widget.eventId,
    'personId': personId,
  });
  if (response.statusCode == 200) {
    // For each subevent that the user is currently joined in, leave it.
    for (var subevent in widget.subevents) {
      if (subevent.status == 'accepted') {
       await _leaveSubEvent(subevent);
      }
    }
    setState(() {
      status = "rejected";
    });

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

  Widget buildSubeventsPage() {
    if (widget.subevents.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey),
        Text(
          "Subevents",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        ...widget.subevents.map((subevent) {
          return ListTile(
            title: Text(subevent.name),
            subtitle: Text("${_formatTime(subevent.startTime)} - ${_formatTime(subevent.endTime)}"),
          );
        }).toList(),
      ],
    );
  }

  Widget buildSubevents() {
  if (widget.subevents.isEmpty) return Container();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Divider(color: Colors.grey),
      Text(
        "Subevents",
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      ...widget.subevents.map((subevent) {
        // Determine the button text, color, and onPressed action.
        String buttonText = subevent.status == 'accepted' ? 'Leave' : 'Join';
        Color buttonColor = _isParticipantSimple()
            ? (subevent.status == 'accepted' ? Colors.red : Colors.green)
            : Colors.grey; // Disabled color if not joined to the main event.

        // If the main event isn't joined, disable the button (i.e. onPressed is null).
        VoidCallback? onPressed = _isParticipantSimple()
            ? (subevent.status == 'accepted'
                ? () => _leaveSubEvent(subevent)
                : () => _joinSubEvent(subevent))
            : null;

        return ListTile(
          title: Text(subevent.name),
          subtitle: Text(
              "${_formatTime(subevent.startTime)} - ${_formatTime(subevent.endTime)}"),
          trailing: _buildStatusButton(buttonText, onPressed, buttonColor),
        );
      }).toList(),
    ],
  );
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
              buildSubeventsPage(),
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
                subevents: widget.subevents,
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
                  buildSubevents(),
                
              ],
            ),
          ),
        ),
      );
    }
  }
}
