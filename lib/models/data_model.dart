import 'dart:convert';
import 'package:flutter/material.dart';
import 'bike_station.dart';
import 'place.dart';
import 'package:bikeapp/services /data_service.dart'; // Remplacez l'espace par un underscore si besoin
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:bikeapp/services /geocoding_service.dart';
import 'package:http/http.dart' as http;

class DataModel with ChangeNotifier {
  List<BikeStation> _stations = [];
  List<BikeStation> _filteredStations = [];
  List<Place> _places = [];

  List<BikeStation> get stations => _stations;
  List<BikeStation> get filteredStations => _filteredStations;
  List<Place> get places => _places;

  Position? _userPosition;

  Position? get userPosition => _userPosition;

  void setStations(List<BikeStation> stations) {
    _stations = stations;
    _filteredStations = stations;
    notifyListeners();
  }

  void filterStations(String query) {
    if (query.isEmpty) {
      _filteredStations = _stations;
    } else {
      _filteredStations = _stations
          .where((station) => station.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> fetchBikeStations() async {
    try {
      DataService dataService = DataService();
      final fetchedStations = await dataService.fetchBikeStations();
      setStations(fetchedStations);
    } catch (error) {
      print('Error fetching bike stations: $error');
    }
  }

  void removePlace(String placeId) {
    _places.removeWhere((place) => place.id == placeId);
    notifyListeners();
  }

  void updatePlace(String placeId, String newName) {
    final placeIndex = _places.indexWhere((place) => place.id == placeId);
    if (placeIndex != -1) {
      _places[placeIndex] = Place(
        id: _places[placeIndex].id,
        name: newName,
        latitude: _places[placeIndex].latitude,
        longitude: _places[placeIndex].longitude,
      );
      notifyListeners();
    }
  }

  void toggleFavorite(String stationId) {
    final stationIndex = _stations.indexWhere((station) => station.id == stationId);
    if (stationIndex != -1) {
      _stations[stationIndex].isFavorite = !_stations[stationIndex].isFavorite;
      notifyListeners();
    }
  }

  // Nouvelle méthode pour trier les stations par disponibilité relative
  void sortStationsByAvailability() {
    _filteredStations.sort((a, b) {
      double availabilityRatioA = a.capacity > 0 ? (a.availableBikes / a.capacity) : 0.0;
      double availabilityRatioB = b.capacity > 0 ? (b.availableBikes / b.capacity) : 0.0;
      return availabilityRatioB.compareTo(availabilityRatioA); // Tri par disponibilité relative décroissante
    });
    notifyListeners();
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Le service de localisation est désactivé.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Les autorisations de localisation sont refusées.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Les autorisations de localisation sont refusées en permanence.');
      return;
    }

    _userPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }

  Future<Map<String, double>?> getCoordinatesFromInput(String input) async {
    try {
      // API Nominatim d'OpenStreetMap pour obtenir les coordonnées
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeFull(input)}&format=json&limit=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty) {
          final location = data[0];
          print('Coordonnées trouvées pour "$input" : ${location['lat']}, ${location['lon']}');
          return {
            'latitude': double.parse(location['lat']),
            'longitude': double.parse(location['lon']),
          };
        } else {
          print('Aucun résultat trouvé pour "$input".');
        }
      } else {
        print('Erreur de géocodage : ${response.statusCode}. Vérifiez l\'entrée ou la connexion.');
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des coordonnées : $e');
    }

    return null;
  }

  // Modifiez cette méthode dans votre classe DataModel
  Future<void> addPlace(String nameOrAddress) async {
    final coordinates = await getCoordinatesFromInput(nameOrAddress);

    if (coordinates != null) {
      final newPlace = Place(
        id: DateTime.now().toString(),
        name: nameOrAddress,
        latitude: coordinates['latitude']!,
        longitude: coordinates['longitude']!,
      );

      _places.add(newPlace);
      notifyListeners();
    } else {
      print("Impossible d'obtenir les coordonnées pour l'entrée donnée.");
    }
  }
}