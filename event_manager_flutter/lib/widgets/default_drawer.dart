// lib/widgets/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person_model.dart';
// import '../models/enums/role_type_enum.dart'; // Adjust the import path as necessary
import '../providers/auth_provider.dart';
import '../providers/person_provider.dart';

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume that AuthProvider and PersonProvider are provided above in the tree.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    // Here, _currentPerson might be stored in PersonProvider, so adjust as needed.
    final PersonModel? currentPerson = personProvider.currentPerson;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message at the top
                  Text(
                    'Welcome, ${currentPerson?.firstName ?? ''} ${currentPerson?.surname ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Role and Group at the bottom
                  Text(
                    'Role: ${currentPerson?.role.toString().split('.').last ?? ''}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (currentPerson?.role == RoleTypeEnum.DEVELOPER &&
                      currentPerson?.group != null)
                    Text(
                      'Group: ${currentPerson?.group.toString().split('.').last}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Events'),
            onTap: () {
              Navigator.pushNamed(context, '/events');
            },
          ),
          ListTile(
            title: const Text('People'),
            onTap: () {
              Navigator.pushNamed(context, '/people');
            },
          ),
          ListTile(
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          ListTile(
            title: const Text('Log out'),
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
