import 'dart:convert';
import 'dart:isolate';
import 'package:frontend/domain/entities/piece_rechange.dart';
import 'package:frontend/domain/repositories/piece_rechange_repository.dart';
import 'package:frontend/infrastructure/http/authenticated_client.dart';

List<PieceRechange> _parsePiecesRechange(String responseBody) {
  final responseData = jsonDecode(responseBody);
  final List<dynamic> data = responseData['data'] ?? [];
  return data.map((map) => PieceRechange.fromMap(map)).toList();
}

class HttpPieceRechangeRepository implements PieceRechangeRepository {
  final String baseUrl =
      'https://ec2-34-254-90-255.eu-west-1.compute.amazonaws.com/api/asset';
  final AuthenticatedClient _client;

  HttpPieceRechangeRepository(this._client);

  @override
  Future<PieceRechange> getPieceRechangeById(String id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/pieces-rechange/$id'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return PieceRechange.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to load piece rechange (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<List<PieceRechange>> getPiecesRechange() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/pieces-rechange?per_page=100'),
    );

    if (response.statusCode == 200) {
      // ⚡ Bolt Optimization: Offload expensive JSON parsing and mapping
      // to a background isolate using Isolate.run(). This prevents the main thread
      // from blocking during the synchronous decode of potentially large arrays,
      // avoiding UI jank. Expected impact: significantly smoother animations and interactions
      // while fetching data on lower-end devices or Web.
      return Isolate.run(() => _parsePiecesRechange(response.body));
    } else {
      throw Exception(
        'Failed to load pieces rechange (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<PieceRechange> createPieceRechange(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/pieces-rechange'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return PieceRechange.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to create piece rechange (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<PieceRechange> updatePieceRechange(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/pieces-rechange/$id'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return PieceRechange.fromMap(responseData['data'] ?? responseData);
    } else {
      throw Exception(
        'Failed to update piece rechange (Status Code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<void> deletePieceRechange(String id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/pieces-rechange/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete piece rechange (Status Code: ${response.statusCode})',
      );
    }
  }
}
