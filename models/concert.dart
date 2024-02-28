class Concert {
  int? id;
  String? nomGroupe;
  DateTime dateHeure;
  int? tarif;
  List<double>? longitude;
  List<double>? latitude;
  String? email;
  String? imageNom;
  String? imageRepo;
  String? referent;
  String? adresse;

  Concert({
    this.id,
    required this.nomGroupe,
    required this.dateHeure,
    required this.tarif,
    required this.longitude,
    required this.latitude,
    required this.email,
    required this.imageNom,
    required this.imageRepo,
    required this.referent,
    required this.adresse,
  });
  Concert.with3Arguments({
    this.id,
    required this.nomGroupe,
    required this.dateHeure,
    required this.tarif,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'nomGroupe': this.nomGroupe,
      'dateHeure': this.dateHeure.toIso8601String(),
      'tarif': this.tarif,
      'longitude': this.longitude,
      'latitude': this.latitude,
      'email': this.email,
      'imageNom': this.imageNom,
      'imageRepo': this.imageRepo,
      'referent': this.referent,
      'adresse': this.adresse,
    };
  }

  factory Concert.fromMap(Map<String, dynamic> map) {
    return Concert(
      id: map['Id'] as int?,
      nomGroupe: map['NomGroupe'] as String,
      dateHeure: DateTime.parse(map['DateHeure'] as String),
      tarif: map['Tarif'] as int,
      longitude: (map['Longitude'] as String).split(',').map((e) => double.parse(e)).toList(),
      latitude: (map['Latitude'] as String).split(',').map((e) => double.parse(e)).toList(),
      email: map['Email'] as String,
      imageNom: map['ImageNom'] as String,
      imageRepo: map['ImageRepo'] as String,
      referent: map['Referent'] as String,
      adresse: map['Adresse'] as String,
    );
  }

  @override
  String toString() {
    return 'Concert{id: $id, nomGroupe: $nomGroupe, dateHeure: $dateHeure, tarif: $tarif, longitude: $longitude, latitude: $latitude, email: $email, imageNom: $imageNom, imageRepo: $imageRepo, referent: $referent, adresse: $adresse}';
  }

}
