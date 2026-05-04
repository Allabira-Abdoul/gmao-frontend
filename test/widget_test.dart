import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App dummy test', (WidgetTester tester) async {
    // Infrastructure
    final counterRepository = InMemoryCounterRepository();
    final authRepository = HttpAuthRepository();

    // Application
    final getCounterUseCase = GetCounterUseCase(counterRepository);
    final incrementCounterUseCase = IncrementCounterUseCase(counterRepository);
    final loginUseCase = LoginUseCase(authRepository);

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

    // Initial route is /login, so wait for it to load
    await tester.pump();

    // We expect the widget to not crash and show something
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
