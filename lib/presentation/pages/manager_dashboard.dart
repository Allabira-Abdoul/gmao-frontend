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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.assessment_outlined,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenue, ${user?.email}',
              style: GoogleFonts.inter(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Accès Windows / Web autorisé'),
            const SizedBox(height: 32),
            Text(
              'Modules',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildNavCard(
                  context,
                  icon: Icons.precision_manufacturing,
                  title: 'Équipements',
                  subtitle: 'Voir et gérer les actifs',
                  color: const Color(0xFF10B981),
                  route: '/equipements',
                ),
                _buildNavCard(
                  context,
                  icon: Icons.inventory_2,
                  title: 'Pièces de Rechange',
                  subtitle: 'Suivre le stock de pièces',
                  color: const Color(0xFFF59E0B),
                  route: '/pieces-rechange',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return SizedBox(
      width: 260,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
