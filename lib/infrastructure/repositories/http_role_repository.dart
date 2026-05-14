import 'dart:convert';
import 'dart:isolate';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/role_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

List<Role> _parseRoles(String responseBody) {
  final responseData = jsonDecode(responseBody);
  final List<dynamic> data = responseData['data'] ?? [];
  return data.map((map) => Role.fromMap(map)).toList();
}

class HttpRoleRepository implements RoleRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/user';
  final AuthenticatedClient _client;

  HttpRoleRepository(this._client);

  @override
  Future<List<Role>> getRoles() async {
    final response = await _client.get(Uri.parse('$baseUrl/roles'));

    if (response.statusCode == 200) {
      // ⚡ Bolt Optimization: Offload expensive JSON parsing and mapping
      // to a background isolate using Isolate.run(). This prevents the main thread
      // from blocking during the synchronous decode of potentially large arrays,
      // avoiding UI jank. Expected impact: significantly smoother animations and interactions
      // while fetching data on lower-end devices or Web.
      return Isolate.run(() => _parseRoles(response.body));
    } else {
      throw Exception(
        'Failed to load roles (Status Code: ${response.statusCode})',
      );
    }
  }
}
