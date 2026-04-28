import 'package:flutter/material.dart';

// Infrastructure (Adapters)
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';

// Application (Use Cases)
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';

// Presentation
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/pages/home_page.dart';

/// Application entry point — acts as the **Composition Root**.
///
/// All dependency wiring happens here:
///   Infrastructure → Application → Presentation
///
/// No layer references a layer it shouldn't:
///   Domain   → (nothing)
///   Application → Domain
///   Infrastructure → Domain
///   Presentation → Application
void main() {
  // 1. Infrastructure layer — choose concrete adapters
  final counterRepository = InMemoryCounterRepository();
  //
  // 2. Application layer — create use cases with injected ports
  final getCounterUseCase = GetCounterUseCase(counterRepository);
  final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

  // 3. Presentation layer — create state with injected use cases
  final counterState = CounterState(
    getCounterUseCase: getCounterUseCase,
    incrementCounterUseCase: incrementCounterUseCase,
  );

  runApp(MyApp(counterState: counterState));
}

class MyApp extends StatelessWidget {
  final CounterState counterState;

  const MyApp({super.key, required this.counterState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMAO Frontend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(counterState: counterState),
    );
  }
}
