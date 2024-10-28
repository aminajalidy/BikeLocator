import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_model.dart';
import '../models/place.dart';
import 'nearby_stations_screen.dart';

class PlacesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataModel = Provider.of<DataModel>(context);
    final places = dataModel.places;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lieux favoris'),
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            title: Text(place.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, place, dataModel);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    dataModel.removePlace(place.id);
                  },
                ),
              ],
            ),
            onTap: () {
              // Afficher les parkings autour de ce lieu
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NearbyStationsScreen(place: place),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, dataModel);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, DataModel dataModel) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un lieu'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Nom du lieu ou adresse'),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                await dataModel.addPlace(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, Place place, DataModel dataModel) {
    TextEditingController nameController = TextEditingController();
    nameController.text = place.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le lieu'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Nom du lieu'),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                dataModel.updatePlace(place.id, nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
