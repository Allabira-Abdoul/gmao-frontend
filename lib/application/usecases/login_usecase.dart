import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthToken> execute(String email, String password) async {
    return await _repository.login(email, password);
  }
}
