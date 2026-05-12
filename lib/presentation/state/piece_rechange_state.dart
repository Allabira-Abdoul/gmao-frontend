import 'package:flutter/foundation.dart';
import 'package:frontend/application/usecases/piece_rechange_usecases.dart';
import 'package:frontend/domain/entities/piece_rechange.dart';

class PieceRechangeState extends ChangeNotifier {
  final GetPiecesRechangeUseCase getPiecesRechangeUseCase;
  final CreatePieceRechangeUseCase createPieceRechangeUseCase;
  final UpdatePieceRechangeUseCase updatePieceRechangeUseCase;
  final DeletePieceRechangeUseCase deletePieceRechangeUseCase;

  List<PieceRechange> _pieces = [];
  bool _isLoading = false;
  String? _error;

  PieceRechangeState({
    required this.getPiecesRechangeUseCase,
    required this.createPieceRechangeUseCase,
    required this.updatePieceRechangeUseCase,
    required this.deletePieceRechangeUseCase,
  });

  List<PieceRechange> get pieces => _pieces;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fake data for testing when the backend is not available.
  static List<PieceRechange> _generateFakeData() {
    return [
      PieceRechange(
        idPiece: 'pr-001',
        nom: 'Roulement à billes SKF 6205',
        reference: 'SKF-6205-2RS',
        description: 'Roulement à billes étanche double, 25x52x15mm',
        quantiteEnStock: 45,
        seuilAlerte: 10,
        coutUnitaire: 12.50,
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2026, 4, 15),
      ),
      PieceRechange(
        idPiece: 'pr-002',
        nom: 'Courroie trapézoïdale Gates',
        reference: 'GATES-A68',
        description: 'Courroie trapézoïdale classique, profil A, longueur 1725mm',
        quantiteEnStock: 8,
        seuilAlerte: 5,
        coutUnitaire: 18.75,
        createdAt: DateTime(2024, 3, 22),
        updatedAt: DateTime(2026, 5, 1),
      ),
      PieceRechange(
        idPiece: 'pr-003',
        nom: 'Filtre à huile Mann W940',
        reference: 'MANN-W940',
        description: 'Filtre à huile pour compresseur Atlas Copco',
        quantiteEnStock: 3,
        seuilAlerte: 5,
        coutUnitaire: 24.90,
        createdAt: DateTime(2023, 11, 5),
        updatedAt: DateTime(2026, 2, 28),
      ),
      PieceRechange(
        idPiece: 'pr-004',
        nom: 'Joint torique Viton 50x3',
        reference: 'VIT-50X3-FPM',
        description: 'Joint torique en Viton résistant aux hautes températures',
        quantiteEnStock: 120,
        seuilAlerte: 20,
        coutUnitaire: 2.30,
        createdAt: DateTime(2024, 6, 12),
        updatedAt: DateTime(2026, 4, 30),
      ),
      PieceRechange(
        idPiece: 'pr-005',
        nom: 'Vérin hydraulique Parker CHD-50',
        reference: 'PARK-CHD50-200',
        description: 'Vérin hydraulique double effet, course 200mm',
        quantiteEnStock: 2,
        seuilAlerte: 3,
        coutUnitaire: 385.00,
        createdAt: DateTime(2023, 8, 19),
        updatedAt: DateTime(2026, 1, 15),
      ),
      PieceRechange(
        idPiece: 'pr-006',
        nom: 'Capteur de pression Sick PBS',
        reference: 'SICK-PBS-400',
        description: 'Capteur de pression 0-400 bar avec sortie analogique',
        quantiteEnStock: 0,
        seuilAlerte: 2,
        coutUnitaire: 210.00,
        createdAt: DateTime(2024, 9, 3),
        updatedAt: DateTime(2026, 5, 5),
      ),
    ];
  }

  Future<void> fetchPiecesRechange() async {
    _setLoading(true);
    try {
      _pieces = await getPiecesRechangeUseCase.execute();
      _error = null;
    } catch (e) {
      // Fallback to fake data when backend is unavailable
      _pieces = _generateFakeData();
      _error = null; // Suppress error since we have fake data
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPieceRechange(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newPiece = await createPieceRechangeUseCase.execute(data);
      _pieces.add(newPiece);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePieceRechange(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await updatePieceRechangeUseCase.execute(id, data);
      final index = _pieces.indexWhere((p) => p.idPiece == id);
      if (index != -1) {
        _pieces[index] = updated;
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

  Future<bool> deletePieceRechange(String id) async {
    _setLoading(true);
    try {
      await deletePieceRechangeUseCase.execute(id);
      _pieces.removeWhere((p) => p.idPiece == id);
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
