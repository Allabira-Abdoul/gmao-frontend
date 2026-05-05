import 'dart:convert';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

class HttpUserRepository implements UserRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final AuthenticatedClient _client;

  HttpUserRepository(this._client);

  @override
  Future<User> getCurrentUser(String token) async {
    final response = await _client.get(Uri.parse('$baseUrl/users/me'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to load current user: ${response.body}');
    }
  }

  @override
  Future<List<User>> getUsers(String token) async {
    final response =
        await _client.get(Uri.parse('$baseUrl/users?per_page=100'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      return data.map((map) => User.fromMap(map)).toList();
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  @override
  Future<User> createUser(String token, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to create user: ${response.body}');
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
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  @override
  Future<void> deleteUser(String token, String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}
