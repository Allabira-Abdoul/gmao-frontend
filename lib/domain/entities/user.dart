class Role {
  final String id;
  final String libelle;
  final String description;
  final List<String> privileges;

  Role({
    required this.id,
    required this.libelle,
    required this.description,
    required this.privileges,
  });

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id_role'] ?? '',
      libelle: map['libelle'] ?? '',
      description: map['description'] ?? '',
      privileges: List<String>.from(map['privileges'] ?? []),
    );
  }
}

class User {
  final String id;
  final String nomComplet;
  final String email;
  final String statutCompte;
  final String idRole;
  final String role;
  final List<String> privileges;

  User({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.statutCompte,
    required this.idRole,
    required this.role,
    required this.privileges,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    // Handle nested role object from API or flat role string from JWT
    String roleName = '';
    List<String> privilegesList = [];

    if (map['role'] is Map) {
      roleName = map['role']['libelle'] ?? '';
      privilegesList = List<String>.from(map['role']['privileges'] ?? []);
    } else {
      roleName = map['role'] ?? '';
      privilegesList = List<String>.from(map['privileges'] ?? []);
    }

    return User(
      id: map['id_utilisateur'] ?? map['user_id'] ?? '',
      nomComplet: map['nom_complet'] ?? '',
      email: map['email'] ?? '',
      statutCompte: map['statut_compte'] ?? 'ACTIVE',
      idRole: map['id_role'] ?? '',
      role: roleName,
      privileges: privilegesList,
    );
  }
}

class AuthToken {
  final String accessToken;
  final String refreshToken;

  AuthToken({required this.accessToken, required this.refreshToken});
}
