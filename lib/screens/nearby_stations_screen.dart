import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../models/place.dart';
import '../widgets/station_card.dart';

class NearbyStationsScreen extends StatelessWidget {
  final Place place;

  NearbyStationsScreen({required this.place});

  @override
  Widget build(BuildContext context) {
    // Utilisation correcte avec listen: true
    final dataModel = Provider.of<DataModel>(context, listen: true);
    final stations = dataModel.stations.where((station) {
      double distance = _calculateDistance(
        station.latitude,
        station.longitude,
        place.latitude,
        place.longitude,
      );
      return distance < 1.0; // Filtrer les stations à moins d'un kilomètre
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Stations près de ${place.name}')),
      body: stations.isEmpty
          ? Center(child: Text('Aucune station à proximité'))
          : ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          return StationCard(
            station: stations[index],
            onToggleFavorite: () {
              dataModel.toggleFavorite(stations[index].id);
            },
          );
        },
      ),
    );
  }
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    double dLat = (lat2 - lat1) * (pi / 180.0);
    double dLon = (lon2 - lon1) * (pi / 180.0);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) * (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

}
