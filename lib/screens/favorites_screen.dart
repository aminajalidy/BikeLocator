// screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../widgets/station_card.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataModel = Provider.of<DataModel>(context);
    final favoriteStations = dataModel.stations.where((station) => station.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Stations favorites')),
      body: ListView.builder(
        itemCount: favoriteStations.length,
        itemBuilder: (context, index) {
          final station = favoriteStations[index]; // Get the favorite station instance

          return StationCard(
            station: station, // Pass the instance of the favorite station
            onToggleFavorite: () {
              // Call the method to toggle the favorite state
              Provider.of<DataModel>(context, listen: false).toggleFavorite(station.id);
            },
          );
        },
      ),
    );
  }
}
