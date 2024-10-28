class Place {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Créez une méthode pour convertir un lieu en JSON si vous souhaitez le stocker localement
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Créez une méthode pour convertir un JSON en lieu
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
