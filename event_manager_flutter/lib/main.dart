import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/person_provider.dart';
import 'providers/event_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/people_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PersonProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: EventManagerApp(),
    ),
  );
}

class EventManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventsScreen(),
        '/people': (context) => PeopleScreen(),
        // Add other routes
      },
    );
  }
}