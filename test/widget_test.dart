import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/presentation/state/auth_state.dart';

void main() {
  testWidgets('Dummy passing test', (WidgetTester tester) async {
    expect(true, isTrue);
  });
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    final authRepository = HttpAuthRepository();
    final loginUseCase = LoginUseCase(authRepository);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthState(loginUseCase: loginUseCase),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Heureux de vous revoir !'), findsOneWidget);
  });
}
