import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/role_repository.dart';

class HttpRoleRepository implements RoleRepository {
  final String baseUrl = 'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final http.Client _client;

  HttpRoleRepository(this._client);

  @override
  Future<List<Role>> getRoles(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/roles'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      return data.map((map) => Role.fromMap(map)).toList();
    } else {
      throw Exception('Failed to load roles: ${response.body}');
    }
  }
}
