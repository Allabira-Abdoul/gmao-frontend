import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/repositories/role_repository.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository repository;
  GetCurrentUserUseCase(this.repository);
  Future<User> execute() => repository.getCurrentUser();
}

class GetUsersUseCase {
  final UserRepository repository;
  GetUsersUseCase(this.repository);
  Future<List<User>> execute() => repository.getUsers();
}

class CreateUserUseCase {
  final UserRepository repository;
  CreateUserUseCase(this.repository);
  Future<User> execute(Map<String, dynamic> data) => repository.createUser(data);
}

class UpdateUserUseCase {
  final UserRepository repository;
  UpdateUserUseCase(this.repository);
  Future<User> execute(String id, Map<String, dynamic> data) => repository.updateUser(id, data);
}

class DeleteUserUseCase {
  final UserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> execute(String id) => repository.deleteUser(id);
}

class GetRolesUseCase {
  final RoleRepository repository;
  GetRolesUseCase(this.repository);
  Future<List<Role>> execute() => repository.getRoles();
}
