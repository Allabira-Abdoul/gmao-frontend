enum EquipementStatus {
  enService('EN_SERVICE'),
  enMaintenance('EN_MAINTENANCE'),
  enPanne('EN_PANNE'),
  reforme('REFORME');

  final String value;
  const EquipementStatus(this.value);

  factory EquipementStatus.fromString(String value) {
    return EquipementStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EquipementStatus.enService,
    );
  }
}

enum EquipementCriticite {
  basse('BASSE'),
  moyenne('MOYENNE'),
  haute('HAUTE');

  final String value;
  const EquipementCriticite(this.value);

  factory EquipementCriticite.fromString(String value) {
    return EquipementCriticite.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EquipementCriticite.basse,
    );
  }
}

class Equipement {
  final String idEquipement;
  final String nom;
  final String code;
  final String description;
  final EquipementStatus statut;
  final DateTime dateAcquisition;
  final String localisation;
  final EquipementCriticite criticite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipement({
    required this.idEquipement,
    required this.nom,
    required this.code,
    required this.description,
    required this.statut,
    required this.dateAcquisition,
    required this.localisation,
    required this.criticite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipement.fromMap(Map<String, dynamic> map) {
    return Equipement(
      idEquipement: map['id_equipement'] ?? '',
      nom: map['nom'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      statut: EquipementStatus.fromString(map['statut'] ?? ''),
      dateAcquisition: DateTime.tryParse(map['date_acquisition'] ?? '') ?? DateTime.now(),
      localisation: map['localisation'] ?? '',
      criticite: EquipementCriticite.fromString(map['criticite'] ?? ''),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_equipement': idEquipement,
      'nom': nom,
      'code': code,
      'description': description,
      'statut': statut.value,
      'date_acquisition': dateAcquisition.toIso8601String(),
      'localisation': localisation,
      'criticite': criticite.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
