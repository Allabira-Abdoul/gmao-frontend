import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Infrastructure (Adapters)
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';

// Application (Use Cases)
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';

// Presentation
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/pages/home_page.dart';
import 'package:frontend/presentation/pages/login_page.dart';

void main() {
  final counterRepository = InMemoryCounterRepository();
  final getCounterUseCase = GetCounterUseCase(counterRepository);
  final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

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
      title: 'GMAO Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF764BA2),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
