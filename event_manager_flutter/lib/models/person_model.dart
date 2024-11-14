// lib/models/user_model.dart

enum RoleTypeEnum { MANAGER, DEVELOPER }
enum GroupTypeEnum { RED, GREEN, BLUE, YELLOW }


class PersonModel {
  final int id;
  final String firstName;
  final String surname;
  final RoleTypeEnum role;
  final GroupTypeEnum? group;
  final String token;
  final int userId;

  PersonModel({
    required this.id,
    required this.firstName,
    required this.surname,
    required this.role,
    this.group,
    required this.token,
    required this.userId,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'],
      firstName: json['firstName'],
      surname: json['surname'],
      role: _roleTypeEnumFromString(json['role']),
      group: json['group'] != null ? _groupTypeEnumFromString(json['group']) : null,
      token: json['token'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'surname': surname,
      'role': _roleTypeEnumToString(role),
      'group': group != null ? _groupTypeEnumToString(group!) : null,
      'token': token,
      'userId': userId,
    };
  }

  // Helper methods to convert enum to/from string
  static RoleTypeEnum _roleTypeEnumFromString(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return RoleTypeEnum.MANAGER;
      case 'developer':
        return RoleTypeEnum.DEVELOPER;
      default:
        throw Exception('Unknown role type: $role');
    }
  }

  static String _roleTypeEnumToString(RoleTypeEnum role) {
    return role.toString().split('.').last;
  }

  static GroupTypeEnum _groupTypeEnumFromString(String group) {
    switch (group.toLowerCase()) {
      case 'red':
        return GroupTypeEnum.RED;
      case 'green':
        return GroupTypeEnum.GREEN;
      case 'blue':
        return GroupTypeEnum.BLUE;
      case 'yellow':
        return GroupTypeEnum.YELLOW;
      default:
        throw Exception('Unknown group type: $group');
    }
  }

  static String _groupTypeEnumToString(GroupTypeEnum group) {
    return group.toString().split('.').last;
  }
}