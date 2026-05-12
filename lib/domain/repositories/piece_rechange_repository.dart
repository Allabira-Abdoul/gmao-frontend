import 'package:frontend/domain/entities/piece_rechange.dart';

/// PieceRechange repository interface.
/// 🏛️ SOLID: Dependency Inversion Principle (DIP) & Interface Segregation Principle (ISP)
abstract class PieceRechangeRepository {
  Future<PieceRechange> getPieceRechangeById(String id);
  Future<List<PieceRechange>> getPiecesRechange();
  Future<PieceRechange> createPieceRechange(Map<String, dynamic> data);
  Future<PieceRechange> updatePieceRechange(String id, Map<String, dynamic> data);
  Future<void> deletePieceRechange(String id);
}
