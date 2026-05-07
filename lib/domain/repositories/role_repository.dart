import 'package:frontend/domain/entities/user.dart';

/// Role repository interface.
/// 🏛️ SOLID: Dependency Inversion Principle (DIP) & Interface Segregation Principle (ISP)
/// By removing the explicit infrastructure-level `token` parameter from the Domain layer,
/// we ensure the domain models the pure business rules. The infrastructure handles injection.
abstract class RoleRepository {
  Future<List<Role>> getRoles();
}
