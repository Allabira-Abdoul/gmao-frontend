import 'dart:convert';
import 'dart:isolate';
import 'package:frontend/domain/entities/equipement.dart';
import 'package:frontend/domain/repositories/equipement_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

List<Equipement> _parseEquipements(String responseBody) {
  final responseData = jsonDecode(responseBody);
  final List<dynamic> data = responseData['data'] ?? [];
  return data.map((map) => Equipement.fromMap(map)).toList();
}

class HttpEquipementRepository implements EquipementRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/asset';
  final AuthenticatedClient _client;

  HttpEquipementRepository(this._client);

  @override
  Future<Equipement> getEquipementById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/equipements/$id'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Equipement.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to load equipement (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<List<Equipement>> getEquipements() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/equipements?per_page=100'),
    );

    if (response.statusCode == 200) {
      // ⚡ Bolt Optimization: Offload expensive JSON parsing and mapping
      // to a background isolate using Isolate.run(). This prevents the main thread
      // from blocking during the synchronous decode of potentially large arrays,
      // avoiding UI jank. Expected impact: significantly smoother animations and interactions
      // while fetching data on lower-end devices or Web.
      return Isolate.run(() => _parseEquipements(response.body));
    } else {
      throw Exception(
        'Failed to load equipements (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<Equipement> createEquipement(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/equipements'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Equipement.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to create equipement (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<Equipement> updateEquipement(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/equipements/$id'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Equipement.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to update equipement (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<void> deleteEquipement(String id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/equipements/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete equipement (Status Code: ${response.statusCode})',
      );
    }
  }
}
