class BikeStation {
  final String id; // Doit être String
  final String name;
  final double latitude;
  final double longitude;
  final int availableBikes;
  final int capacity;
  bool isFavorite;

  BikeStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableBikes,
    required this.capacity,
    this.isFavorite = false,
  });

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      id: json['@id'].toString(), // Convertir en String si nécessaire
      name: json['nom'] ?? 'Unknown',
      latitude: json['y']?.toDouble() ?? 0.0,
      longitude: json['x']?.toDouble() ?? 0.0,
      availableBikes: json['nb_velos_dispo'] ?? 0,
      capacity: (json['nb_places_dispo'] ?? 0) + (json['nb_velos_dispo'] ?? 0),
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
