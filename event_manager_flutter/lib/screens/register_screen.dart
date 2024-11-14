// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/person_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  RoleTypeEnum? _selectedRole;
  GroupTypeEnum? _selectedGroup;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select a role';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        surname: _surnameController.text.trim(),
        role: _selectedRole!,
        group: _selectedGroup,
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DropdownMenuItem<RoleTypeEnum>> get _roleDropdownItems {
    return RoleTypeEnum.values
        .map((role) => DropdownMenuItem(
              value: role,
              child: Text(role.toString().split('.').last),
            ))
        .toList();
  }

  List<DropdownMenuItem<GroupTypeEnum>> get _groupDropdownItems {
    return GroupTypeEnum.values
        .map((group) => DropdownMenuItem(
              value: group,
              child: Text(group.toString().split('.').last),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                ),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter an email';
                    final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return 'Invalid email';
                    return null;
                  },
                ),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your first name' : null,
                ),
                // Surname Field
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(labelText: 'Surname'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your surname' : null,
                ),
                SizedBox(height: 20),
                // Role Dropdown
                DropdownButtonFormField<RoleTypeEnum>(
                  value: _selectedRole,
                  items: _roleDropdownItems,
                  decoration: InputDecoration(labelText: 'Role'),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a role' : null,
                ),
                SizedBox(height: 20),
                // Group Dropdown (Optional)
                DropdownButtonFormField<GroupTypeEnum>(
                  value: _selectedGroup,
                  items: _groupDropdownItems,
                  decoration: InputDecoration(labelText: 'Group (Optional)'),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroup = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Error Message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 20),
                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child:
                      _isLoading ? CircularProgressIndicator() : Text('Register'),
                ),
                SizedBox(height: 10),
                // Login Button
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}