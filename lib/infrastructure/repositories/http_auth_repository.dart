import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  final String baseUrl =
      'http://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/authentication';

  @override
  Future<AuthToken> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'mot_de_passe': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final data = responseData['data'];
      return AuthToken(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'] ?? '',
      );
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Failed to login');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final data = responseData['data'];
      return AuthToken(
        accessToken: data['access_token'] ?? '',
        refreshToken: data['refresh_token'] ?? '',
      );
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
