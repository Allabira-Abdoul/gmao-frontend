import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/auth_state.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthState>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Manager', style: GoogleFonts.outfit()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthState>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Bienvenue, ${user?.email}', style: GoogleFonts.inter(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Accès Windows / Web autorisé'),
          ],
        ),
      ),
    );
  }
}
