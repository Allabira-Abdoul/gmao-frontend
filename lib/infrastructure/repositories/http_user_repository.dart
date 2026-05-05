import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

List<User> _parseUsers(String responseBody) {
  final responseData = jsonDecode(responseBody);
  final List<dynamic> data = responseData['data'] ?? [];
  return data.map((map) => User.fromMap(map)).toList();
}

class HttpUserRepository implements UserRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final http.Client _client;

  HttpUserRepository(this._client);

  @override
  Future<User> getCurrentUser(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to load current user (Status Code: ${response.statusCode})');
    }
  }

  @override
  Future<List<User>> getUsers(String token) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/users?per_page=100',
      ), // Fetch more users for simple table
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return _parseUsers(response.body);
    } else {
      throw Exception('Failed to load users (Status Code: ${response.statusCode})');
    }
  }

  @override
  Future<User> createUser(String token, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to create user (Status Code: ${response.statusCode})');
    }
  }

  @override
  Future<User> updateUser(
    String token,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to update user (Status Code: ${response.statusCode})');
    }
  }

  @override
  Future<void> deleteUser(String token, String id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user (Status Code: ${response.statusCode})');
    }
  }
}
