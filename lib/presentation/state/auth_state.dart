import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/application/usecases/refresh_token_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthState({
    required LoginUseCase loginUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
  }) : _loginUseCase = loginUseCase,
       _refreshTokenUseCase = refreshTokenUseCase;

  String? _accessToken;
  String? get accessToken => _accessToken;

  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await logout();
        return false;
      }

      final tokens = await _refreshTokenUseCase.execute(refreshToken);

      // Update storage and memory
      await _storage.write(key: 'access_token', value: tokens.accessToken);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
      _accessToken = tokens.accessToken;

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        // Handle dummy tokens
        if (token.startsWith('dummy_')) {
          String role = 'Technicien';
          if (token.contains('admin')) role = 'Administrateur';
          if (token.contains('manager')) role = 'Manager';

          _currentUser = User(
            id: 'dummy-id',
            nomComplet: 'Dummy $role',
            email: 'dummy@test.com',
            statutCompte: 'ACTIVE',
            idRole: 'dummy-role-id',
            role: role,
            privileges: [],
          );
          _accessToken = token;
          _status = AuthStatus.authenticated;
          notifyListeners();
          return;
        }

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
      // Dummy logins for testing
      if (email.endsWith('@dummy.com')) {
        String role = 'Technicien';
        String tokenType = 'tech';
        if (email.startsWith('admin')) {
          role = 'Administrateur';
          tokenType = 'admin';
        } else if (email.startsWith('manager')) {
          role = 'Manager';
          tokenType = 'manager';
        }

        final dummyToken = 'dummy_${tokenType}_token';

        await _storage.write(key: 'access_token', value: dummyToken);
        await _storage.write(key: 'refresh_token', value: dummyToken);

        _currentUser = User(
          id: 'dummy-id',
          nomComplet: 'Dummy $role',
          email: email,
          statutCompte: 'ACTIVE',
          idRole: 'dummy-role-id',
          role: role,
          privileges: [],
        );
        _accessToken = dummyToken;

        _status = AuthStatus.authenticated;
        notifyListeners();
        return;
      }

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

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _currentUser = null;
    _accessToken = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
