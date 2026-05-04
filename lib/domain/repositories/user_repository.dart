import 'package:frontend/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers(String token);
  Future<User> createUser(String token, Map<String, dynamic> data);
  Future<User> updateUser(String token, String id, Map<String, dynamic> data);
  Future<void> deleteUser(String token, String id);
}
