import 'package:event_manager_flutter/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/person_provider.dart';
import 'providers/event_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/people_screen.dart';
import 'screens/calendar_screen.dart';
import 'services/real_time_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadUserData();
  final realTimeService = RealTimeService();

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PersonProvider(realTimeService: realTimeService, authProvider: authProvider)),
        ChangeNotifierProvider(create: (_) => EventProvider(realTimeService: realTimeService, authProvider: authProvider)),
        Provider<RealTimeService>(create: (_) => RealTimeService()), // Add RealTimeService provider
      ],
      child: EventManagerApp(),
    ),
  );
}

class EventManagerApp extends StatelessWidget {
  const EventManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthProvider by loading persisted user data
    Provider.of<AuthProvider>(context, listen: false).loadUserFromPrefs().then((_) {
      // After loading user, load current person
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final personProvider = Provider.of<PersonProvider>(context, listen: false);
        personProvider.loadCurrentPerson(context);
      }
    });

    final ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
    );

    // Define the dark theme
    final ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      // Customize the dark theme colors as needed
    );

    return MaterialApp(
      title: 'Event Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentUser != null) {
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
        '/calendar': (context) => CalendarScreen(),
        '/profile': (context) => const ProfileScreen(),
        // '/register' : (context) => RegisterScreen(),
        // Add other routes
      },
    );
  }
}