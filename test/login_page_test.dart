import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/presentation/pages/login_page.dart';
import 'package:frontend/presentation/state/auth_state.dart';
import 'package:frontend/application/usecases/login_usecase.dart';
import 'package:frontend/infrastructure/repositories/http_auth_repository.dart';

void main() {
  testWidgets('LoginPage password visibility toggle test', (WidgetTester tester) async {
    final authRepository = HttpAuthRepository();
    final authState = AuthState(loginUseCase: LoginUseCase(authRepository));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authState),
          ],
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Password field should be obscured by default
    final Finder passwordFieldFinder = find.byType(TextField).last;
    TextField passwordField = tester.widget(passwordFieldFinder);
    expect(passwordField.obscureText, isTrue);

    // Find the visibility toggle icon button and tap it
    final visibilityToggleFinder = find.byIcon(Icons.visibility_off);
    expect(visibilityToggleFinder, findsOneWidget);

    await tester.tap(visibilityToggleFinder);
    await tester.pumpAndSettle();

    // Password field should now not be obscured
    passwordField = tester.widget(passwordFieldFinder);
    expect(passwordField.obscureText, isFalse);

    // Find visibility icon and tap it
    final visibilityToggleFinderOn = find.byIcon(Icons.visibility);
    expect(visibilityToggleFinderOn, findsOneWidget);

    await tester.tap(visibilityToggleFinderOn);
    await tester.pumpAndSettle();

    // Password field should be obscured again
    passwordField = tester.widget(passwordFieldFinder);
    expect(passwordField.obscureText, isTrue);
  });
}
