import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/presentation/state/auth_state.dart';

/// A web-compatible HTTP helper that proactively refreshes the access token
/// before each request if it is expired, then injects the Bearer header.
///
/// This avoids using [http.BaseClient.send()] overrides which rely on
/// dart:io primitives (RawReceivePort) incompatible with Flutter Web.
class AuthenticatedClient {
  final AuthState authState;
  final http.Client _inner;

  AuthenticatedClient(this.authState, this._inner);

  /// Returns valid headers with an up-to-date Authorization token.
  /// Refreshes the token first if it is expired.
  Future<Map<String, String>> authenticatedHeaders([
    Map<String, String> extra = const {},
  ]) async {
    await _ensureFreshToken();
    return {
      'Content-Type': 'application/json',
      if (authState.accessToken != null)
        'Authorization': 'Bearer ${authState.accessToken}',
      ...extra,
    };
  }

  Future<http.Response> get(Uri url) async {
    final headers = await authenticatedHeaders();
    final response = await _inner.get(url, headers: headers);
    if (response.statusCode == 401) {
      return _retryGet(url);
    }
    return response;
  }

  Future<http.Response> post(Uri url, {Object? body}) async {
    final headers = await authenticatedHeaders();
    final response = await _inner.post(url, headers: headers, body: body);
    if (response.statusCode == 401) {
      return _retryPost(url, body: body);
    }
    return response;
  }

  Future<http.Response> put(Uri url, {Object? body}) async {
    final headers = await authenticatedHeaders();
    final response = await _inner.put(url, headers: headers, body: body);
    if (response.statusCode == 401) {
      return _retryPut(url, body: body);
    }
    return response;
  }

  Future<http.Response> delete(Uri url) async {
    final headers = await authenticatedHeaders();
    final response = await _inner.delete(url, headers: headers);
    if (response.statusCode == 401) {
      return _retryDelete(url);
    }
    return response;
  }

  // ── Retry helpers (called after a 401) ──────────────────────────────────

  Future<http.Response> _retryGet(Uri url) async {
    final refreshed = await authState.refreshTokens();
    if (!refreshed) return http.Response('Unauthorized', 401);
    final headers = await authenticatedHeaders();
    return _inner.get(url, headers: headers);
  }

  Future<http.Response> _retryPost(Uri url, {Object? body}) async {
    final refreshed = await authState.refreshTokens();
    if (!refreshed) return http.Response('Unauthorized', 401);
    final headers = await authenticatedHeaders();
    return _inner.post(url, headers: headers, body: body);
  }

  Future<http.Response> _retryPut(Uri url, {Object? body}) async {
    final refreshed = await authState.refreshTokens();
    if (!refreshed) return http.Response('Unauthorized', 401);
    final headers = await authenticatedHeaders();
    return _inner.put(url, headers: headers, body: body);
  }

  Future<http.Response> _retryDelete(Uri url) async {
    final refreshed = await authState.refreshTokens();
    if (!refreshed) return http.Response('Unauthorized', 401);
    final headers = await authenticatedHeaders();
    return _inner.delete(url, headers: headers);
  }

  // ── Token freshness ─────────────────────────────────────────────────────

  Future<void> _ensureFreshToken() async {
    final token = authState.accessToken;
    if (token != null && JwtDecoder.isExpired(token)) {
      await authState.refreshTokens();
    }
  }

  void close() => _inner.close();
}
