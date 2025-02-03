import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user_frontend/services/api_service.dart';
import 'package:user_frontend/widgets/text_filter.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  Map<String, dynamic>? _teamData;
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTeam();
  }

  Future<void> _fetchTeam() async {
    try {
      final response = await ApiService.get('/teams/my-team/users');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _teamData = data;
          _filteredUsers = data['users'];
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _teamData = {'name': 'No team found', 'users': []};
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
      _filteredUsers = _teamData!['users']
          .where((user) =>
              '${user['first_name']} ${user['last_name']}'.toLowerCase().contains(query.toLowerCase()))
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
                      Text(
                        '${_teamData!['name']}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                                          '${user['first_name'][0]}${user['last_name'][0]}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        '${user['first_name']} ${user['last_name']}',
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
