import 'package:frontend/domain/entities/piece_rechange.dart';
import 'package:frontend/domain/repositories/piece_rechange_repository.dart';

class GetPiecesRechangeUseCase {
  final PieceRechangeRepository repository;
  GetPiecesRechangeUseCase(this.repository);
  Future<List<PieceRechange>> execute() => repository.getPiecesRechange();
}

class GetPieceRechangeByIdUseCase {
  final PieceRechangeRepository repository;
  GetPieceRechangeByIdUseCase(this.repository);
  Future<PieceRechange> execute(String id) =>
      repository.getPieceRechangeById(id);
}

class CreatePieceRechangeUseCase {
  final PieceRechangeRepository repository;
  CreatePieceRechangeUseCase(this.repository);
  Future<PieceRechange> execute(Map<String, dynamic> data) =>
      repository.createPieceRechange(data);
}

class UpdatePieceRechangeUseCase {
  final PieceRechangeRepository repository;
  UpdatePieceRechangeUseCase(this.repository);
  Future<PieceRechange> execute(String id, Map<String, dynamic> data) =>
      repository.updatePieceRechange(id, data);
}

class DeletePieceRechangeUseCase {
  final PieceRechangeRepository repository;
  DeletePieceRechangeUseCase(this.repository);
  Future<void> execute(String id) => repository.deletePieceRechange(id);
}
