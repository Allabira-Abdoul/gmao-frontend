import 'package:frontend/domain/entities/counter.dart';
import 'package:frontend/domain/repositories/counter_repository.dart';

/// Adapter: In-memory implementation of [CounterRepository].
///
/// This is the infrastructure layer implementation of the domain port.
/// It can be swapped for an API-backed or local-storage-backed
/// implementation without touching the domain or application layers.
class InMemoryCounterRepository implements CounterRepository {
  Counter _counter = const Counter();

  @override
  Future<Counter> getCounter() async {
    return _counter;
  }

  @override
  Future<void> saveCounter(Counter counter) async {
    _counter = counter;
  }
}
