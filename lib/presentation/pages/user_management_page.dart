import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/user_management_state.dart';
import 'package:frontend/presentation/widgets/user_form_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementState>().fetchUsersAndRoles();
    });
  }

  void _showUserForm([String? userId]) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(userId: userId),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await context.read<UserManagementState>().deleteUser(id);
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(success ? 'Utilisateur supprimé' : 'Erreur lors de la suppression'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: () => context.read<UserManagementState>().fetchUsersAndRoles(),
          ),
        ],
      ),
      body: Consumer<UserManagementState>(
        builder: (context, state, child) {
          if (state.isLoading && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.users.isEmpty) {
            return Center(child: Text('Erreur: ${state.error}'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop/Large screen view
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nom Complet')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Rôle')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: state.users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.nomComplet)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.role)),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.statutCompte,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: user.statutCompte == 'ACTIVE' ? Colors.green : Colors.red,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Éditer l\'utilisateur',
                                    onPressed: () => _showUserForm(user.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Supprimer l\'utilisateur',
                                    onPressed: () => _confirmDelete(user.id, user.nomComplet),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                // Mobile screen view
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    user.nomComplet.isNotEmpty ? user.nomComplet : 'Sans Nom',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    user.statutCompte,
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                  backgroundColor: user.statutCompte == 'ACTIVE' ? Colors.green : Colors.red,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(user.email, style: const TextStyle(color: Colors.grey))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.badge, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(user.role, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                  label: const Text('Éditer', style: TextStyle(color: Colors.blue)),
                                  onPressed: () => _showUserForm(user.id),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _confirmDelete(user.id, user.nomComplet),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        tooltip: 'Ajouter un utilisateur',
        child: const Icon(Icons.add),
      ),
    );
  }
}
