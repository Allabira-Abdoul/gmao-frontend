class User {
  final String id;
  final String email;
  final String role;
  final List<String> privileges;

  User({
    required this.id,
    required this.email,
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
      email: map['email'] ?? '',
      role: roleName,
      privileges: privilegesList,
    );
  }
}

class AuthToken {
  final String accessToken;
  final String refreshToken;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
  });
}
