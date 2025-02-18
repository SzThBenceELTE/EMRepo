import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user_frontend/services/api_service.dart';
import 'package:user_frontend/services/auth_service.dart';
import 'package:user_frontend/widgets/text_filter.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<dynamic>? _teamData;
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTeam();
  }

  Future<Map<String,dynamic>?> _fetchPerson() async {
    return AuthService.getPerson();
  }

  Future<void> _fetchTeam() async {
    try {
      
      final person = await _fetchPerson();
      print("Person: $person");
      print("Person ID: ${person!['id']}");

      final route = '/people/${person['id']}/teams';

      final response = await ApiService.get(route);

      print("Response: ${response.body}");


      final decodedResponse = jsonDecode(response.body);
      print(decodedResponse);
      final teamId = decodedResponse[0]['id'];

      final teamRoute = '/teams/$teamId/members';
      final teamMates = await ApiService.get(teamRoute);
      print("Team mates: $teamMates");

      final decodedTeamMates = jsonDecode(teamMates.body);
      print(decodedTeamMates);
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _teamData = decodedResponse;
          _users = decodedTeamMates;
          _filteredUsers = decodedTeamMates;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _teamData = [];
          _users = [];
          _filteredUsers = [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch team details');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsersByName(String query) {
    setState(() {
      _filteredUsers = _users!
          .where((user) =>
              '${user['firstName']} ${user['surname']}'.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   '${_teamData!['name']}',
                      //   style: TextStyle(
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      SizedBox(height: 8),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_filteredUsers.length} members',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFilter(
                        onTextChanged: _filterUsersByName,
                        hintText: 'Filter members by name',
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: _filteredUsers.isEmpty
                            ? Center(
                                child: Text(
                                  'No members match your search',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          '${(user['firstName'] as String)[0]}${(user['surname'] as String)[0]}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        '${user['firstName']} ${user['surname']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
