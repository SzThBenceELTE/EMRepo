import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_frontend/pages/events_page.dart';
import 'package:user_frontend/services/event_service.dart';
import 'package:user_frontend/widgets/event_widget.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final PageController _pageController = PageController();
  DateTime _selectedDay = DateTime.utc(2025, 10, 16);
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    var events = await EventService.fetchEvents();
    setState(() {
      events['events'].forEach((event) {
        var date = DateTime.parse(event['date']);
        _events[date] = [event];
      });
    });
  }

  List<dynamic> _getEventForDay(DateTime day) {
    DateTime formattedDate = DateTime.parse(
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}');
    return _events[formattedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Calendar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2022, 01, 01),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: _getEventForDay,
                        calendarBuilders: CalendarBuilders(
                          singleMarkerBuilder: (context, day, event) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    (event as Map<String, dynamic>)["status"] ==
                                                'accepted' ||
                                            event["status"] == 'applied'
                                        ? Colors.green
                                        : event["status"] == "rejected"
                                            ? Colors.red
                                            : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              width: 7.0,
                              height: 7.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                            );
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          canMarkersOverflow: false,
                          markersAutoAligned: true,
                          markersAnchor: 1.1,
                          selectedDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 28, 10, 97),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                      ),
                      SizedBox(height: 20.0),
                      if (_getEventForDay(_selectedDay).length > 0)
                        EventWidget.fromMap(
                          _getEventForDay(_selectedDay).first,
                          onStatusChanged: () {
                            setState(() {
                              _fetchEvents();
                            });
                          },
                        ),
                    ],
                  ),
                ),
                EventsPage(onlyAccepted: true),
                EventsPage(
                  pastEvents: true,
                  onlyAccepted: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: WormEffect(
              dotHeight: 8.0,
              dotWidth: 8.0,
              spacing: 16.0,
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
