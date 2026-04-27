import 'package:frontend/domain/entities/counter.dart';

/// Port (abstract interface) for counter persistence.
///
/// This defines what the domain layer *needs* from the outside world,
/// without specifying *how* it is implemented.
abstract class CounterRepository {
  Future<Counter> getCounter();
  Future<void> saveCounter(Counter counter);
}
