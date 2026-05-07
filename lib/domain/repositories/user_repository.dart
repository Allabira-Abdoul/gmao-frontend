import 'package:frontend/domain/entities/user.dart';

/// User repository interface.
/// 🏛️ SOLID: Dependency Inversion Principle (DIP) & Interface Segregation Principle (ISP)
/// By removing the explicit infrastructure-level `token` parameter from the Domain layer,
/// we ensure the domain models the pure business rules. The infrastructure handles injection.
abstract class UserRepository {
  Future<User> getCurrentUser();
  Future<List<User>> getUsers();
  Future<User> createUser(Map<String, dynamic> data);
  Future<User> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}
