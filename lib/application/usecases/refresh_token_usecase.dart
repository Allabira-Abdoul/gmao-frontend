import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthToken> execute(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
