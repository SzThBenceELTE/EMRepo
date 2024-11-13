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
    // Initialize AuthProvider by loading persisted user data
    Provider.of<AuthProvider>(context, listen: false).loadUserFromPrefs();

    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentPerson != null) {
            return EventsScreen();
          } else {
            return LoginScreen();
          }
        },
      ),

      //initialRoute: '/',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventsScreen(),
        '/people': (context) => PeopleScreen(),
        // Add other routes
      },
    );
  }
}