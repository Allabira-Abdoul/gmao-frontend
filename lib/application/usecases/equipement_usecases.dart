import 'package:frontend/domain/entities/equipement.dart';
import 'package:frontend/domain/repositories/equipement_repository.dart';

class GetEquipementsUseCase {
  final EquipementRepository repository;
  GetEquipementsUseCase(this.repository);
  Future<List<Equipement>> execute() => repository.getEquipements();
}

class GetEquipementByIdUseCase {
  final EquipementRepository repository;
  GetEquipementByIdUseCase(this.repository);
  Future<Equipement> execute(String id) => repository.getEquipementById(id);
}

class CreateEquipementUseCase {
  final EquipementRepository repository;
  CreateEquipementUseCase(this.repository);
  Future<Equipement> execute(Map<String, dynamic> data) =>
      repository.createEquipement(data);
}

class UpdateEquipementUseCase {
  final EquipementRepository repository;
  UpdateEquipementUseCase(this.repository);
  Future<Equipement> execute(String id, Map<String, dynamic> data) =>
      repository.updateEquipement(id, data);
}

class DeleteEquipementUseCase {
  final EquipementRepository repository;
  DeleteEquipementUseCase(this.repository);
  Future<void> execute(String id) => repository.deleteEquipement(id);
}
