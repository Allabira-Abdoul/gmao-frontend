import 'dart:convert';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/role_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

class HttpRoleRepository implements RoleRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final AuthenticatedClient _client;

  HttpRoleRepository(this._client);

  @override
  Future<List<Role>> getRoles(String token) async {
    final response = await _client.get(Uri.parse('$baseUrl/roles'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      return data.map((map) => Role.fromMap(map)).toList();
    } else {
      throw Exception(
        'Failed to load roles (Status Code: ${response.statusCode})',
      );
    }
  }
}
