// lib/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String email;
  final int personId;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.personId,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      personId: json['personId'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'personId': personId,
      'token': token,
    };
  }
}