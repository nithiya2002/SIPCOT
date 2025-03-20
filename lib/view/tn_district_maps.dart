import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/map_vm.dart';
import 'package:flutter/services.dart' show rootBundle;

class TnDistrictMaps extends StatefulWidget {
  const TnDistrictMaps({super.key});
  @override
  State<TnDistrictMaps> createState() => _TnDistrictMapsState();
}

class _TnDistrictMapsState extends State<TnDistrictMaps> {
  GoogleMapController? _mapController;
  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    Provider.of<MapViewModel>(
      context,
      listen: false,
    ).fetchPolygonsFromGeoServer();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
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
              zoom: 7,
            ),
            polygons: mapViewModel.polygons,
            markers: mapViewModel.markers, // Added
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _mapController!.setMapStyle(_mapStyle);
            },
          );
        },
      ),
    );
  }
}
