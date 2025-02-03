import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_frontend/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {

  
  static Future<http.Response> login(String username, String password) async {
    http.Response response = await ApiService.post(
        '/auth/login', {'username': username, 'password': password});

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      String token = responseData['token'];

      await FlutterSecureStorage().write(key: 'auth_token', value: token);
    }
    return response;
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    String? token = await FlutterSecureStorage().read(key: 'auth_token');
    return token != null ? Jwt.parseJwt(token) : null;
  }

  static Future<void> logout() async {
    await FlutterSecureStorage().delete(key: 'auth_token');
  }

  static Future<String?> getToken() async {
    return await FlutterSecureStorage().read(key: 'auth_token');
  }


}
