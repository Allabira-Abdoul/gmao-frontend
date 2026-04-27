import 'package:frontend/domain/entities/counter.dart';
import 'package:frontend/domain/repositories/counter_repository.dart';

/// Application use case: Get the current counter value.
class GetCounterUseCase {
  final CounterRepository _repository;

  GetCounterUseCase(this._repository);

  Future<Counter> execute() async {
    return await _repository.getCounter();
  }
}
