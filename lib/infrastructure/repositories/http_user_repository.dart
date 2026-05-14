import 'dart:convert';
import 'dart:isolate';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

List<User> _parseUsers(String responseBody) {
  final responseData = jsonDecode(responseBody);
  final List<dynamic> data = responseData['data'] ?? [];
  return data.map((map) => User.fromMap(map)).toList();
}

class HttpUserRepository implements UserRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final AuthenticatedClient _client;

  HttpUserRepository(this._client);

  @override
  Future<User> getCurrentUser() async {
    final response = await _client.get(Uri.parse('$baseUrl/users/me'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception(
        'Failed to load current user (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<List<User>> getUsers() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users?per_page=100'),
    );

    if (response.statusCode == 200) {
      // ⚡ Bolt Optimization: Offload expensive JSON parsing and mapping
      // to a background isolate using Isolate.run(). This prevents the main thread
      // from blocking during the synchronous decode of potentially large arrays,
      // avoiding UI jank. Expected impact: significantly smoother animations and interactions
      // while fetching data on lower-end devices or Web.
      return Isolate.run(() => _parseUsers(response.body));
    } else {
      throw Exception(
        'Failed to load users (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/users'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception(
        'Failed to create user (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/users/$id'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromMap(responseData['data']);
    } else {
      throw Exception(
        'Failed to update user (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete user (Status Code: ${response.statusCode})',
      );
    }
  }
}
