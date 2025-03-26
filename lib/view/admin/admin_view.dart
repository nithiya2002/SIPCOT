import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sipcot/viewModel/auth_view_model.dart';
import 'package:sipcot/viewModel/map_vm.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'addPointScreen.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  String _mapStyle = '';
  late GoogleMapController mapController;
  bool _isInitialized = false;

  void _onMapCreated(
    GoogleMapController controller,
    MapViewModel mapviewmodel,
  ) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    if (mapviewmodel.polygonsSite.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        _moveToSiteBoundary();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapData();
    });
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
  }

  Future<void> _initializeMapData() async {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    await Future.wait([
      mapViewModel.fetchPolygonData(),
      mapViewModel.fetchSiteBoundary(),
      mapViewModel.fetchFieldPoints(),
      mapViewModel.fetchNewBoundary(),
      mapViewModel.fetchCadastralData("SIPCOT"),
      mapViewModel.fetchFMBData("SIPCOT"),
    ]);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _moveToSiteBoundary() {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    if (mapViewModel.polygonsSite.isEmpty) return;
    final bounds = _calculateBounds(mapViewModel.polygonsSite);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }

  LatLngBounds _calculateBounds(Set<Polygon> polygons) {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;
    for (var polygon in polygons) {
      for (var point in polygon.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
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
      appBar: AppBar(
        title: const Text('SIPCOT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final mapViewModel = Provider.of<MapViewModel>(context, listen: false);

              // Get the current map camera position
              mapController.getVisibleRegion().then((bounds) {
                LatLng centerPoint = LatLng(
                    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) / 2
                );

                // Get survey number suggestions
                List<dynamic> surveySuggestions = mapViewModel.getSurveySuggestions();

                // Navigate to the add point screen
                Get.to(() => AddPointScreen(
                  selectedLocation: centerPoint,
                  surveySuggestions: surveySuggestions,
                ));
              });
            },
            tooltip: "Add a new survey",
          ),
          // Add site boundary focus button
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _moveToSiteBoundary,
            tooltip: "Focus on Site Boundary",
          ),
          // Add refresh button for field points
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final mapViewModel = Provider.of<MapViewModel>(
                context,
                listen: false,
              );
              // Refresh all data
              mapViewModel.fetchSiteBoundary();
              mapViewModel.fetchFieldPoints();
              mapViewModel.fetchCadastralData("SIPCOT");
              mapViewModel.fetchFMBData("SIPCOT");
            },
            tooltip: "Refresh Map Data",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthViewModel>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<MapViewModel>(
            builder: (context, mapViewModel, child) {
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _onMapCreated(controller, mapViewModel);
                },
                mapType: MapType.satellite,
                initialCameraPosition: CameraPosition(
                  target: initialCameraPosition!,
                  zoom: 10.0,
                ),
                polygons: {
                  ...mapViewModel.polygons,
                  ...mapViewModel.polygonsSite,
                  ...mapViewModel.newBoundaryPolygons,
                  ...mapViewModel.cascadeBoundaryPolygons,
                  ...mapViewModel.fmbBoundaryPolygon,
                },
                markers: {
                  ...mapViewModel.markers,
                  ...mapViewModel.fieldPoints,
                  ...mapViewModel.cascadeMakers,
                  ...mapViewModel.fmb_marker,
                },
              );
            },
          ),
          // Loading indicator
          Consumer<MapViewModel>(
            builder: (context, mapViewModel, child) {
              if (mapViewModel.isLoadingSiteBoundary) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text("Loading site boundary..."),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

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

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              value: mapViewModel.showNewBoundary,
                              onChanged: (value) {
                                mapViewModel.toggleNewBoundary(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text('New Boundary', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              value: mapViewModel.showCascadeBoundary,
                              onChanged: (value) {
                                mapViewModel.toggleCascade(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text('Cadastral Map', style: TextStyle(fontSize: 12)),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              value: mapViewModel.showFmbBoundary,
                              onChanged: (value) {
                                mapViewModel.toggleFMB(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text('FMB Map', style: TextStyle(fontSize: 12)),
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
