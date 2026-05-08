import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/auth_state.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthState>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Administrateur', style: GoogleFonts.outfit()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mon Profil',
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              context.read<AuthState>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings_outlined,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenue, ${user?.email}',
              style: GoogleFonts.inter(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Accès Windows / Web autorisé'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/admin/users');
              },
              icon: const Icon(Icons.people),
              label: const Text('Gestion des Utilisateurs'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
