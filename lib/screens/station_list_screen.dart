import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../widgets/station_card.dart';
import '../widgets/search_bar.dart' as custom;

class StationListScreen extends StatefulWidget {
  @override
  _StationListScreenState createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Appeler fetchBikeStations uniquement lors de l'initialisation
      Provider.of<DataModel>(context, listen: false).fetchBikeStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation correcte avec listen: true
    final dataModel = Provider.of<DataModel>(context, listen: true);
    final stations = _showFavoritesOnly
        ? dataModel.filteredStations.where((station) => station.isFavorite).toList()
        : dataModel.filteredStations;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bike Locator'),
        actions: [
          IconButton(
            icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // Appeler la méthode de tri
              dataModel.sortStationsByAvailability();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Rafraîchir les données uniquement lorsque l'utilisateur effectue un swipe-down
          await dataModel.fetchBikeStations();
        },
        child: Column(
          children: [
            custom.SearchBar(
              controller: _searchController,
              onSearch: (text) {
                dataModel.filterStations(text);
              },
            ),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}
