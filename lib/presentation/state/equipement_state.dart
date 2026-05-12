import 'package:flutter/foundation.dart';
import 'package:frontend/application/usecases/equipement_usecases.dart';
import 'package:frontend/domain/entities/equipement.dart';

class EquipementState extends ChangeNotifier {
  final GetEquipementsUseCase getEquipementsUseCase;
  final CreateEquipementUseCase createEquipementUseCase;
  final UpdateEquipementUseCase updateEquipementUseCase;
  final DeleteEquipementUseCase deleteEquipementUseCase;

  List<Equipement> _equipements = [];
  bool _isLoading = false;
  String? _error;

  EquipementState({
    required this.getEquipementsUseCase,
    required this.createEquipementUseCase,
    required this.updateEquipementUseCase,
    required this.deleteEquipementUseCase,
  });

  List<Equipement> get equipements => _equipements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fake data for testing when the backend is not available.
  static List<Equipement> _generateFakeData() {
    return [
      Equipement(
        idEquipement: 'eq-001',
        nom: 'Compresseur Atlas Copco GA-30',
        code: 'COMP-001',
        description: 'Compresseur à vis rotatif 30kW pour atelier principal',
        statut: EquipementStatus.enService,
        dateAcquisition: DateTime(2022, 3, 15),
        localisation: 'Atelier A - Zone Nord',
        criticite: EquipementCriticite.haute,
        createdAt: DateTime(2022, 3, 15),
        updatedAt: DateTime(2025, 11, 1),
      ),
      Equipement(
        idEquipement: 'eq-002',
        nom: 'Tour CNC Mazak QT-250',
        code: 'CNC-002',
        description: 'Tour numérique haute précision pour usinage',
        statut: EquipementStatus.enMaintenance,
        dateAcquisition: DateTime(2021, 7, 20),
        localisation: 'Atelier B - Zone Usinage',
        criticite: EquipementCriticite.haute,
        createdAt: DateTime(2021, 7, 20),
        updatedAt: DateTime(2026, 1, 10),
      ),
      Equipement(
        idEquipement: 'eq-003',
        nom: 'Pompe hydraulique Parker PV-180',
        code: 'PMP-003',
        description: 'Pompe à débit variable pour presse hydraulique',
        statut: EquipementStatus.enService,
        dateAcquisition: DateTime(2023, 1, 8),
        localisation: 'Atelier C - Zone Presse',
        criticite: EquipementCriticite.moyenne,
        createdAt: DateTime(2023, 1, 8),
        updatedAt: DateTime(2025, 9, 22),
      ),
      Equipement(
        idEquipement: 'eq-004',
        nom: 'Convoyeur à bande Interroll',
        code: 'CONV-004',
        description: 'Convoyeur de transport 12m pour ligne de production',
        statut: EquipementStatus.enPanne,
        dateAcquisition: DateTime(2020, 11, 3),
        localisation: 'Ligne de Production 1',
        criticite: EquipementCriticite.haute,
        createdAt: DateTime(2020, 11, 3),
        updatedAt: DateTime(2026, 5, 1),
      ),
      Equipement(
        idEquipement: 'eq-005',
        nom: 'Chariot élévateur Toyota 8FBN-25',
        code: 'CHAR-005',
        description: 'Chariot élévateur électrique 2.5T',
        statut: EquipementStatus.enService,
        dateAcquisition: DateTime(2024, 2, 14),
        localisation: 'Entrepôt Principal',
        criticite: EquipementCriticite.basse,
        createdAt: DateTime(2024, 2, 14),
        updatedAt: DateTime(2026, 4, 15),
      ),
      Equipement(
        idEquipement: 'eq-006',
        nom: 'Groupe électrogène Caterpillar C-18',
        code: 'GEN-006',
        description: 'Générateur diesel de secours 500 kVA',
        statut: EquipementStatus.reforme,
        dateAcquisition: DateTime(2015, 6, 1),
        localisation: 'Local Technique - Sous-sol',
        criticite: EquipementCriticite.moyenne,
        createdAt: DateTime(2015, 6, 1),
        updatedAt: DateTime(2026, 3, 20),
      ),
    ];
  }

  Future<void> fetchEquipements() async {
    _setLoading(true);
    try {
      _equipements = await getEquipementsUseCase.execute();
      _error = null;
    } catch (e) {
      // Fallback to fake data when backend is unavailable
      _equipements = _generateFakeData();
      _error = null; // Suppress error since we have fake data
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createEquipement(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newEquipement = await createEquipementUseCase.execute(data);
      _equipements.add(newEquipement);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateEquipement(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await updateEquipementUseCase.execute(id, data);
      final index = _equipements.indexWhere((e) => e.idEquipement == id);
      if (index != -1) {
        _equipements[index] = updated;
      }
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteEquipement(String id) async {
    _setLoading(true);
    try {
      await deleteEquipementUseCase.execute(id);
      _equipements.removeWhere((e) => e.idEquipement == id);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
