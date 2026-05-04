import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthState({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase;

  String? _accessToken;
  String? get accessToken => _accessToken;

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        if (!JwtDecoder.isExpired(token)) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          _currentUser = User.fromMap(decodedToken);
          _accessToken = token;
          _status = AuthStatus.authenticated;
          notifyListeners();
          return;
        }
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _loginUseCase.execute(email, password);

      // Persist tokens securely
      await _storage.write(key: 'access_token', value: tokens.accessToken);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);

      // Decode user info from JWT
      Map<String, dynamic> decodedToken = JwtDecoder.decode(tokens.accessToken);
      _currentUser = User.fromMap(decodedToken);
      _accessToken = tokens.accessToken;

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Check if the user is allowed to access the app based on their role and platform.
  /// Returns a redirect path or null if allowed.
  String? getPlatformRedirect() {
    if (_currentUser == null) return '/login';

    final role =
        _currentUser!.role; // e.g., "Technicien", "Manager", "Administrateur"

    // Platform logic
    if (kIsWeb) {
      // Everyone can access web
      return _getDashboardByRole(role);
    } else if (Platform.isAndroid) {
      // Android is for technicien
      if (role == 'Technicien') {
        return '/technicien-dashboard';
      } else {
        return '/unauthorized-platform';
      }
    } else if (Platform.isWindows) {
      // Windows is for the others (Manager, Administrateur)
      if (role == 'Manager' || role == 'Administrateur') {
        return _getDashboardByRole(role);
      } else {
        return '/unauthorized-platform';
      }
    }

    return null;
  }

  String _getDashboardByRole(String role) {
    switch (role) {
      case 'Technicien':
        return '/technicien-dashboard';
      case 'Manager':
        return '/manager-dashboard';
      case 'Administrateur':
        return '/admin-dashboard';
      default:
        return '/login';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _currentUser = null;
    _accessToken = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
