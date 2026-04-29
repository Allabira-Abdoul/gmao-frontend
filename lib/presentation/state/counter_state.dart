import 'package:flutter/foundation.dart';
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';

/// Presentation state manager (ViewModel) for the counter feature.
///
/// Depends only on application-layer use cases, never on infrastructure.
class CounterState extends ChangeNotifier {
  final GetCounterUseCase _getCounterUseCase;
  final IncrementCounterUseCase _incrementCounterUseCase;

  int _counterValue = 0;
  int get counterValue => _counterValue;

  CounterState({
    required GetCounterUseCase getCounterUseCase,
    required IncrementCounterUseCase incrementCounterUseCase,
  }) : _getCounterUseCase = getCounterUseCase,
       _incrementCounterUseCase = incrementCounterUseCase;

  Future<void> loadCounter() async {
    final counter = await _getCounterUseCase.execute();
    // ⚡ Bolt Optimization: Only notify listeners if the value actually changed to prevent unnecessary rebuilds
    if (_counterValue != counter.value) {
      _counterValue = counter.value;
      notifyListeners();
    }
  }

  Future<void> incrementCounter() async {
    final counter = await _incrementCounterUseCase.execute();
    // ⚡ Bolt Optimization: Only notify listeners if the value actually changed to prevent unnecessary rebuilds
    if (_counterValue != counter.value) {
      _counterValue = counter.value;
      notifyListeners();
    }
  }
}
