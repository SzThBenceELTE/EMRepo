import 'package:flutter/material.dart';
import 'package:user_frontend/pages/login_page.dart';
import 'package:user_frontend/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, dynamic>?> _getUserData() async {
    return await AuthService.getUserData();
  }

  Future<Map<String, dynamic>?> _getPerson() async {
    return await AuthService.getPerson();
  }

  void _onLogOutPressed(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await AuthService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getPerson(), //this gets me the user Id, meaning I don't have to find another way of getting it
                                  //Issue: I need to get the person ID aswell
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                      '${userData!['firstName'][0]}${userData['surname'][0]}',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      '${userData['firstName']} ${userData['surname']}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Text(
                    //   'Username: ${userData['username']}',
                    //   style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    // ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _onLogOutPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No user data found'));
          }
        },
      ),
    );
  }
}
