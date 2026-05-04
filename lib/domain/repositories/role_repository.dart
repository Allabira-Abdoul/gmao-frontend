import 'package:frontend/domain/entities/user.dart';

abstract class RoleRepository {
  Future<List<Role>> getRoles(String token);
}
