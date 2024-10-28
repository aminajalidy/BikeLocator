import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bike_station.dart';

class DataService {
  Future<List<BikeStation>> fetchBikeStations() async {
    final response = await http.get(Uri.parse('https://data.lillemetropole.fr/data/ogcapi/collections/vlille_temps_reel/items?f=json&limit=-1'));
    if (response.statusCode == 200) {
      List<BikeStation> fetchedStations = [];
      var responseData = json.decode(utf8.decode(response.bodyBytes));

      if (responseData.containsKey('records')) {
        for (var record in responseData['records']) {
          var properties = record;
          BikeStation station = BikeStation.fromJson(properties);
          fetchedStations.add(station);
        }
        return fetchedStations;
      } else {
        print('No records found in the response');
      }
    } else {
      print('Failed to fetch data');
    }
    return [];
  }
}
