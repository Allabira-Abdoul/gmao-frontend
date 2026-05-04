import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/user_management_state.dart';

class UserFormDialog extends StatefulWidget {
  final String? userId; // If null, it's a create operation

  const UserFormDialog({super.key, this.userId});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomCompletController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  String? _selectedRoleId;
  String _selectedStatus = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _nomCompletController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    if (widget.userId != null) {
      // Pre-fill the form for editing
      final state = context.read<UserManagementState>();
      final user = state.users.firstWhere((u) => u.id == widget.userId);
      _nomCompletController.text = user.nomComplet;
      _emailController.text = user.email;
      _selectedStatus = user.statutCompte;
      // We assume idRole is available in the User entity now
      _selectedRoleId = user.idRole.isNotEmpty ? user.idRole : null;
    }
  }

  @override
  void dispose() {
    _nomCompletController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final state = context.read<UserManagementState>();
      bool success = false;

      final data = {
        'nom_complet': _nomCompletController.text,
        'email': _emailController.text,
        'id_role': _selectedRoleId,
      };

      if (widget.userId == null) {
        // Create
        data['mot_de_passe'] = _passwordController.text;
        success = await state.createUser(data);
      } else {
        // Update
        data['statut_compte'] = _selectedStatus;
        success = await state.updateUser(widget.userId!, data);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.userId == null ? 'Utilisateur créé' : 'Utilisateur mis à jour')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.error ?? "Inconnue"}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<UserManagementState>();
    final isEditing = widget.userId != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifier Utilisateur' : 'Nouvel Utilisateur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomCompletController,
                decoration: const InputDecoration(labelText: 'Nom Complet'),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@') ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),
              if (!isEditing) // Only show password field on creation
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 8 ? 'Minimum 8 caractères' : null,
                ),
              if (!isEditing) const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRoleId,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: state.roles.map((role) {
                  return DropdownMenuItem(
                    value: role.id,
                    child: Text(role.libelle),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedRoleId = value),
                validator: (value) => value == null ? 'Sélectionnez un rôle' : null,
              ),
              if (isEditing) const SizedBox(height: 16),
              if (isEditing)
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Actif')),
                    DropdownMenuItem(value: 'INACTIVE', child: Text('Inactif')),
                    DropdownMenuItem(value: 'LOCKED', child: Text('Verrouillé')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
