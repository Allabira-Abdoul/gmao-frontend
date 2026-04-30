import 'package:frontend/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AuthToken> login(String email, String password);
  Future<void> logout(String refreshToken);
  Future<AuthToken> refreshToken(String refreshToken);
}
