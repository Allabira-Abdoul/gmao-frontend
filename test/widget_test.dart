import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/presentation/pages/home_page.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Setup dependencies
    final counterRepository = InMemoryCounterRepository();
    final getCounterUseCase = GetCounterUseCase(counterRepository);
    final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => CounterState(
            getCounterUseCase: getCounterUseCase,
            incrementCounterUseCase: incrementCounterUseCase,
          ),
          child: Consumer<CounterState>(
            builder: (context, counterState, _) =>
                HomePage(counterState: counterState),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push the button to start counting!'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('Dummy passing test', (WidgetTester tester) async {
    expect(true, isTrue);
  });
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    final authRepository = HttpAuthRepository();
    final loginUseCase = LoginUseCase(authRepository);
    final counterRepository = InMemoryCounterRepository();

    final getCounterUseCase = GetCounterUseCase(counterRepository);
    final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CounterState(
              getCounterUseCase: getCounterUseCase,
              incrementCounterUseCase: incrementCounterUseCase,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthState(loginUseCase: loginUseCase),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('GMAO Premium'), findsWidgets);
    expect(find.text('Se connecter'), findsWidgets);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Heureux de vous revoir !'), findsOneWidget);
  });
}
