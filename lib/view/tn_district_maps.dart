// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:sipcot/viewModel/map_vm.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class TnDistrictMaps extends StatefulWidget {
//   const TnDistrictMaps({super.key});
//   @override
//   State<TnDistrictMaps> createState() => _TnDistrictMapsState();
// }

// class _TnDistrictMapsState extends State<TnDistrictMaps> {
//   GoogleMapController? _mapController;
//   String _mapStyle = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadMapStyle();
//     Provider.of<MapViewModel>(
//       context,
//       listen: false,
//     ).fetchPolygonsFromGeoServer();
//     Provider.of<MapViewModel>(
//       context,
//       listen: false,
//     ).fetchFieldPoints();

//   }

//   Future<void> _loadMapStyle() async {
//     _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Flutter Google Maps with GeoServer")),
//       body: Consumer<MapViewModel>(
//         builder: (context, mapViewModel, child) {
//           return GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(12.9826816, 80.2422784), // Adjust to your location
//               zoom: 7,
//             ),
//             polygons: mapViewModel.polygons,
//             markers: { ...mapViewModel.markers, ...mapViewModel.fieldPoints}, // Added
//             onMapCreated: (GoogleMapController controller) {
//               _mapController = controller;
//               _mapController!.setMapStyle(_mapStyle);
//             },
//           );
//         },
//       ),

//     );
//   }
// }

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

    // Initialize data when screen loads
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    mapViewModel.fetchPolygonsFromGeoServer();
    mapViewModel.fetchFieldPoints();
    mapViewModel.fetchSiteBoundary();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Google Maps with GeoServer"),
        actions: [
          // Add refresh button for field points
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final mapViewModel = Provider.of<MapViewModel>(
                context,
                listen: false,
              );
              mapViewModel.fetchFieldPoints();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map with markers and polygons
          Consumer<MapViewModel>(
            builder: (context, mapViewModel, child) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(12.9826816, 80.2422784),
                  zoom: 7,
                ),
                polygons: {
                  ...mapViewModel.polygons,
                  ...mapViewModel.polygonsSite,
                },
                markers: {...mapViewModel.markers, ...mapViewModel.fieldPoints},
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _mapController!.setMapStyle(_mapStyle);
                  Future.delayed(Duration(milliseconds: 500), () {
                    for (var marker in mapViewModel.fieldPoints) {
                      controller.showMarkerInfoWindow(marker.markerId);
                    }
                  });
                },
              );
            },
          ),

          // Controls panel to toggle field points
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Consumer<MapViewModel>(
                builder: (context, mapViewModel, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              value: mapViewModel.showFieldPoints,
                              onChanged: (value) {
                                mapViewModel.toggleFieldPoints(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text('Show Points', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ), // Small spacing between toggles
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              value: mapViewModel.showSiteBoundary,
                              onChanged: (value) {
                                mapViewModel.toggleSiteBoundary(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text('Site Boundary', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
