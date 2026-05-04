import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/role_repository.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository repository;
  GetUsersUseCase(this.repository);
  Future<List<User>> execute(String token) => repository.getUsers(token);
}

class CreateUserUseCase {
  final UserRepository repository;
  CreateUserUseCase(this.repository);
  Future<User> execute(String token, Map<String, dynamic> data) => repository.createUser(token, data);
}

class UpdateUserUseCase {
  final UserRepository repository;
  UpdateUserUseCase(this.repository);
  Future<User> execute(String token, String id, Map<String, dynamic> data) => repository.updateUser(token, id, data);
}

class DeleteUserUseCase {
  final UserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> execute(String token, String id) => repository.deleteUser(token, id);
}

class GetRolesUseCase {
  final RoleRepository repository;
  GetRolesUseCase(this.repository);
  Future<List<Role>> execute(String token) => repository.getRoles(token);
}
