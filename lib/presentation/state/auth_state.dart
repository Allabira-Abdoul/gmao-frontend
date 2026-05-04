import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthState({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await _loginUseCase.execute(email, password);

      // Persist tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', tokens.accessToken);
      await prefs.setString('refresh_token', tokens.refreshToken);

      // Decode user info from JWT
      Map<String, dynamic> decodedToken = JwtDecoder.decode(tokens.accessToken);
      _currentUser = User.fromMap(decodedToken);

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
