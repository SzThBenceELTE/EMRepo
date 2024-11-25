// lib/models/user_model.dart
enum UserRole { manager, developer }
enum GroupType {RED,GREEN,YELLOW,BLUE}

class UserModel {
  final int id;
  final String name;
  final String email;
  final int personId;
  final UserRole role;
  final String? group; // Only for developers

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.personId,
    required this.role,
    this.group,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("factory: $json");
    print(json['id']);
    print(json['name']);
    print(json['email']);
    print(json['Person']['id']);
    print(json['Person']['role']);
    print(json['Person']['group']);

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      personId: json['Person']['id'],
      role: _parseUserRole(json['Person']['role']),
      group: json['Person']['group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'personId': personId,
      //'token': token,
    };
  }

  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'developer':
        return UserRole.developer;
      default:
        throw Exception('Unknown role type: $role');
    }
  }
  

}