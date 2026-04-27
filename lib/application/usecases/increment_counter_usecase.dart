import 'package:frontend/domain/entities/counter.dart';
import 'package:frontend/domain/repositories/counter_repository.dart';

/// Application use case: Increment the counter.
///
/// Orchestrates the business logic by reading the current counter,
/// applying the domain operation, and persisting the result.
class IncrementCounterUseCase {
  final CounterRepository _repository;

  IncrementCounterUseCase(this._repository);

  Future<Counter> execute() async {
    final counter = await _repository.getCounter();
    final updated = counter.increment();
    await _repository.saveCounter(updated);
    return updated;
  }
}
