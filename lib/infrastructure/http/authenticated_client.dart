import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:frontend/presentation/state/auth_state.dart';

class AuthenticatedClient extends http.BaseClient {
  final AuthState authState;
  final http.Client _inner;

  AuthenticatedClient(this.authState, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // We clone the request because streams can only be consumed once.
    // However, if the request is a simple Request (not StreamedRequest), we can clone it easily.
    // If we want to be safe, we try sending it. If it fails with 401, we clone and retry.
    // Since http.BaseRequest does not have a clone method, we have to manually copy it.
    
    // First, attach the current token if available
    if (authState.accessToken != null) {
      request.headers['Authorization'] = 'Bearer ${authState.accessToken}';
    }

    final initialRequest = await _copyRequest(request);
    
    var response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Token might be expired. Try to refresh.
      final success = await authState.refreshTokens();
      
      if (success && authState.accessToken != null) {
        // Retry with new token
        final retryRequest = await _copyRequest(initialRequest);
        retryRequest.headers['Authorization'] = 'Bearer ${authState.accessToken}';
        return _inner.send(retryRequest);
      }
    }

    return response;
  }

  Future<http.BaseRequest> _copyRequest(http.BaseRequest request) async {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;
      
      if (request.bodyBytes.isNotEmpty) {
        copy.bodyBytes = request.bodyBytes;
      }
      return copy;
    } else if (request is http.MultipartRequest) {
      final copy = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
      return copy;
    } else if (request is http.StreamedRequest) {
      // NOTE: StreamedRequest cannot be easily copied because the stream is consumed.
      // For this app, we mainly use http.Request via client.get, client.post.
      throw Exception('Copying StreamedRequest is not supported');
    }
    
    throw Exception('Unsupported request type');
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
