class PieceRechange {
  final String idPiece;
  final String nom;
  final String reference;
  final String description;
  final int quantiteEnStock;
  final int seuilAlerte;
  final double coutUnitaire;
  final DateTime createdAt;
  final DateTime updatedAt;

  PieceRechange({
    required this.idPiece,
    required this.nom,
    required this.reference,
    required this.description,
    required this.quantiteEnStock,
    required this.seuilAlerte,
    required this.coutUnitaire,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PieceRechange.fromMap(Map<String, dynamic> map) {
    return PieceRechange(
      idPiece: map['id_piece'] ?? '',
      nom: map['nom'] ?? '',
      reference: map['reference'] ?? '',
      description: map['description'] ?? '',
      quantiteEnStock: map['quantite_en_stock'] ?? 0,
      seuilAlerte: map['seuil_alerte'] ?? 0,
      coutUnitaire: (map['cout_unitaire'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_piece': idPiece,
      'nom': nom,
      'reference': reference,
      'description': description,
      'quantite_en_stock': quantiteEnStock,
      'seuil_alerte': seuilAlerte,
      'cout_unitaire': coutUnitaire,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
