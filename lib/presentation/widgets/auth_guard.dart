import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/auth_state.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String requiredRole;

  const AuthGuard({super.key, required this.child, required this.requiredRole});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, _) {
        if (authState.status != AuthStatus.authenticated ||
            authState.currentUser == null) {
          // Add a post-frame callback to avoid state modification during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authState.currentUser!.role != requiredRole) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushReplacementNamed('/unauthorized-platform');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}
