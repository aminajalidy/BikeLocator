import 'package:flutter/material.dart';
import '../models/bike_station.dart';
import 'package:url_launcher/url_launcher.dart';

class StationCard extends StatelessWidget {
  final BikeStation station;
  final VoidCallback onToggleFavorite;

  StationCard({required this.station, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.local_parking,
          color: station.availableBikes == 0
              ? Colors.black
              : station.availableBikes / station.capacity < 0.2
              ? Colors.red
              : Colors.green,
          size: 30,
        ),
        title: Text(station.name),
        subtitle: Text("Bikes: ${station.availableBikes} | Places: ${station.capacity - station.availableBikes}"),
        trailing: IconButton(
          icon: Icon(
            station.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: station.isFavorite ? Colors.red : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: () {
          _launchMaps(station.latitude, station.longitude);
        },
      ),
    );
  }

  void _launchMaps(double latitude, double longitude) async {
    final googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Could not launch Google Maps');
    }
  }
}
