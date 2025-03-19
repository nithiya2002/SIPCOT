import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/map_vm.dart';

class TnDistrictMaps extends StatefulWidget {
  const TnDistrictMaps({super.key});
  @override
  State<TnDistrictMaps> createState() => _TnDistrictMapsState();
}

class _TnDistrictMapsState extends State<TnDistrictMaps> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Provider.of<MapViewModel>(
      context,
      listen: false,
    ).fetchPolygonsFromGeoServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Google Maps with GeoServer")),
      body: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(12.9826816, 80.2422784), // Adjust to your location
              zoom: 10,
            ),
            polygons: mapViewModel.polygons,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          );
        },
      ),
    );
  }
}
