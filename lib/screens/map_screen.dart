import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../models/place.dart';
import '../screens/nearby_stations_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showPlaces = false;
  LatLng? _userLocation;

  @override
  Widget build(BuildContext context) {
    final dataModel = Provider.of<DataModel>(context);
    final places = dataModel.places;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des stations'),
        actions: [
          IconButton(
            icon: Icon(_showPlaces ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showPlaces = !_showPlaces;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () async {
              await dataModel.determinePosition();
              final position = dataModel.userPosition;
              if (position != null) {
                setState(() {
                  _userLocation = LatLng(position.latitude, position.longitude);
                });
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: _userLocation ?? LatLng(50.62925, 3.057256), // Centre par défaut à Lille
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              ...dataModel.stations.map((station) => Marker(
                point: LatLng(station.latitude, station.longitude),
                width: 80,
                height: 80,
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NearbyStationsScreen(
                        place: Place(
                          id: station.id,
                          name: station.name,
                          latitude: station.latitude,
                          longitude: station.longitude,
                        ),
                      ),
                    ));
                  },
                  child: Icon(
                    Icons.local_parking,
                    color: station.availableBikes == 0
                        ? Colors.black
                        : station.availableBikes / station.capacity < 0.2
                        ? Colors.red
                        : Colors.green,
                    size: 40,
                  ),
                ),
              )).toList(),
              if (_showPlaces)
                ...places.map((place) => Marker(
                  point: LatLng(place.latitude, place.longitude),
                  width: 80,
                  height: 80,
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NearbyStationsScreen(place: place),
                      ));
                    },
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                )).toList(),
            ],
          ),
          if (_userLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _userLocation!,
                  width: 80,
                  height: 80,
                  builder: (ctx) => Icon(
                    Icons.my_location,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
