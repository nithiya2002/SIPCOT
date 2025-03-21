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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _initializeMapData();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/localJSON/map_style.json');
  }

  Future<void> _initializeMapData() async {
    // Initialize data when screen loads
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    
    // Fetch site boundary first
    await mapViewModel.fetchSiteBoundary();
    
    // Then fetch the other data
    await Future.wait([
      mapViewModel.fetchPolygonsFromGeoServer(),
      mapViewModel.fetchFieldPoints(),
    ]);
    
    setState(() {
      _isInitialized = true;
    });
  }

  void _moveToSiteBoundary() {
    if (_mapController == null) return;
    
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    if (mapViewModel.polygonsSite.isEmpty) return;
    
    // Calculate the bounds of all site boundary polygons
    final bounds = _calculateBounds(mapViewModel.polygonsSite);
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0), // 50.0 is padding
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text("SIPCOT"),
        actions: [
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
              mapViewModel.fetchPolygonsFromGeoServer();
            },
            tooltip: "Refresh Map Data",
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
                  target: LatLng(10.9899, 77.3329), // Centered closer to Kangeyam
                  zoom: 10,
                ),
                polygons: {
                  ...mapViewModel.polygons,
                  ...mapViewModel.polygonsSite, // This will be empty if showSiteBoundary is false
                },
                markers: {...mapViewModel.markers, ...mapViewModel.fieldPoints},
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  controller.setMapStyle(_mapStyle);
                  
                  // Move to site boundary after map is created (if available)
                  if (mapViewModel.polygonsSite.isNotEmpty) {
                    Future.delayed(Duration(milliseconds: 500), () {
                      _moveToSiteBoundary();
                    });
                  }
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
                      const SizedBox(height: 4), // Small spacing between toggles
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