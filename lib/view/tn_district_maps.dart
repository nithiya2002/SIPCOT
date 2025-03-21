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
  String _mapStyle = '';
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    Provider.of<MapViewModel>(context, listen: false).fetchPolygonData();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    //   mapViewModel.fetchPolygonData();
    // });
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewModel>(context);
    LatLng? initialCameraPosition;
    if (mapViewModel.polygons.isNotEmpty) {
      final firstPolygon = mapViewModel.polygons.first.points;
      if (firstPolygon.isNotEmpty) {
        initialCameraPosition = firstPolygon.first;
      }
    } else {
      initialCameraPosition = const LatLng(12.9826816, 80.2422784);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SIPCOT')),
      body: Consumer<MapViewModel>(
        builder: (context, mapViewModel, child) {
          return GoogleMap(
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition!,
              zoom: 10.0,
            ),
            polygons: mapViewModel.polygons,
            markers: mapViewModel.markers,
          );
        },
      ),
    );
  }
}
