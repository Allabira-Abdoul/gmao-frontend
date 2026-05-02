import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/infrastructure/repositories/in_memory_counter_repository.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/application/usecases/get_counter_usecase.dart';
import 'package:frontend/application/usecases/increment_counter_usecase.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/presentation/state/counter_state.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    final counterRepository = InMemoryCounterRepository();
    final authRepository = HttpAuthRepository();

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
    await tester.pumpAndSettle();

    expect(find.text('GMAO Premium'), findsWidgets);
    expect(find.text('Se connecter'), findsWidgets);
  });
}
