import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/auth_state.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const AuthGuard({super.key, required this.child, required this.allowedRoles});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, _) {
        if (authState.status != AuthStatus.authenticated ||
            authState.currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Vérification de l\'authentification',
              ),
            ),
          );
        }

        if (!allowedRoles.contains(authState.currentUser!.role)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: Text('Accès non autorisé')),
          );
        }

        return child;
      },
    );
  }
}
