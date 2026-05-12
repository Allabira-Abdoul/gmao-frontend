import 'package:frontend/domain/entities/equipement.dart';

/// Equipement repository interface.
/// 🏛️ SOLID: Dependency Inversion Principle (DIP) & Interface Segregation Principle (ISP)
abstract class EquipementRepository {
  Future<Equipement> getEquipementById(String id);
  Future<List<Equipement>> getEquipements();
  Future<Equipement> createEquipement(Map<String, dynamic> data);
  Future<Equipement> updateEquipement(String id, Map<String, dynamic> data);
  Future<void> deleteEquipement(String id);
}
