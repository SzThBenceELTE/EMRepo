import 'package:flutter/material.dart';
import 'package:user_frontend/pages/all_events_page.dart';
import 'package:user_frontend/pages/calendar_page.dart';
import 'profile_page.dart';
import 'team_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedPage = 0;
  final List<Widget> _pages = [
    CalendarPage(),
    AllEventsPage(),
    TeamPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'All Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedPage,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: Center(
        child: _pages[selectedPage],
      ),
    );
  }
}
