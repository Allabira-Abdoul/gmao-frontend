import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/presentation/pages/login_page.dart';

void main() {
  testWidgets('App loads and shows Login Page', (WidgetTester tester) async {
    final authRepository = HttpAuthRepository();
    final loginUseCase = LoginUseCase(authRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthState(loginUseCase: loginUseCase),
            ),
          ],
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsWidgets);
  });
}
