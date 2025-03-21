import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sipcot/CustomFields/customMarker.dart';
import 'package:sipcot/MediaScreen/mediaPreviewScreen.dart';
import 'package:sipcot/model/polygon_model.dart';
import 'package:sipcot/utility/create_custom_icon.dart';
import 'package:turf/turf.dart' as turf;

class MapViewModel extends ChangeNotifier {
  VoidCallback? onNavigateToDetails;
  Set<Polygon> _polygons = {};
  Set<Polygon> _polygonsSite = {};

  Set<Marker> _markers = {};
  Set<Marker> _fieldPoints = {}; // For storing field points from your GeoJSON
  bool _showFieldPoints = true;
  bool _showSiteBoundary = true;
  bool _isLoadingSiteBoundary = false; // Add loading state
  
  Set<Polygon> get polygons => _polygons;
  Set<Polygon> get polygonsSite => _showSiteBoundary ? _polygonsSite : {};
  bool get showSiteBoundary => _showSiteBoundary;
  bool get isLoadingSiteBoundary => _isLoadingSiteBoundary;

  Set<Marker> get markers => _markers;
  Set<Marker> get fieldPoints => _showFieldPoints ? _fieldPoints : {};
  bool get showFieldPoints => _showFieldPoints;

  // Toggle field points visibility
  void toggleFieldPoints(bool value) {
    _showFieldPoints = value;
    notifyListeners();
  }

  void toggleSiteBoundary(bool value){
    _showSiteBoundary = value;
    notifyListeners();
  }

  Future<void> fetchFieldPoints() async {
    try {
      print("Fetching field points...");
      // First try to load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('field_points_data');
      
      Map<String, dynamic> jsonData;
      
      if (savedData == null) {
        // If no saved data, fetch from API
        print("No cached field points found, fetching from API...");
        final response = await http.get(Uri.parse('https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/field_points.geojson'));
        
        if (response.statusCode == 200) {
          // Save to SharedPreferences for offline use
          await prefs.setString('field_points_data', response.body);
          jsonData = json.decode(response.body);
          print("Field points fetched and cached successfully");
        } else {
          throw Exception("Failed to load field points: ${response.statusCode}");
        }
      } else {
        // Use the saved data
        print("Using cached field points data");
        jsonData = json.decode(savedData);
      }
      
      // Process the GeoJSON data
      await _processFieldPointsData(jsonData);
      
    } catch (e) {
      print("Error fetching field points: $e");
    }
  }

  // Process the field points GeoJSON data
  Future<void> _processFieldPointsData(Map<String, dynamic> jsonData) async {
    try {
      print("Processing field points data...");
      // Check if it's a valid GeoJSON FeatureCollection
      if (jsonData['type'] == 'FeatureCollection' &&
          jsonData['features'] is List) {
        Set<Marker> newFieldPoints = {};
        List features = jsonData['features'];
        print("Found ${features.length} field point features");

        for (int i = 0; i < features.length; i++) {
          var feature = features[i];
          var properties = feature['properties'];
          var geometry = feature['geometry'];

          if (geometry['type'] == 'Point' && geometry['coordinates'] is List) {
            // Get coordinates (GeoJSON is [longitude, latitude])
            double longitude = geometry['coordinates'][0];
            double latitude = geometry['coordinates'][1];
            LatLng position = LatLng(latitude, longitude);

            // Get properties
            int pointId = properties['point_id'];
            String parkName = properties['Park_name'] ?? 'Unknown';
            String classification = properties['classification'] ?? 'Unknown';

            BitmapDescriptor markerIcon = await MapUtils.getTriangleMarker(
              classification == 'agriculture' ? Colors.green : Colors.red,
            );
            
            // Create the list of media URLs
            List<String> mediaUrls = [];
            
            // Collect all available images and videos
            for (int i = 1; i <= 4; i++) {
              if (properties["image_$i"] != null && properties["image_$i"].toString().isNotEmpty) {
                mediaUrls.add(properties["image_$i"]);
              }
            }
            
            if (properties["video_1"] != null && properties["video_1"].toString().isNotEmpty) {
              mediaUrls.add(properties["video_1"]);
            }
            
            if (properties["video_2"] != null && properties["video_2"].toString().isNotEmpty) {
              mediaUrls.add(properties["video_2"]);
            }
            
            // Create the marker with proper onTap function
            newFieldPoints.add(
              Marker(
                markerId: MarkerId('field_point_$pointId'),
                position: position,
                icon: markerIcon,
                onTap: () {
                  print("Marker tapped: Point $pointId, Media URLs: ${mediaUrls.length}");
                  // Navigate directly without using a closure
                  if (mediaUrls.isNotEmpty) {
                    Get.to(() => MediaPreviewScreen(mediaUrls: mediaUrls));
                  } else {
                    // Show a snackbar if no media is available
                    Get.snackbar(
                      "No Media",
                      "No images or videos available for this point",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: Duration(seconds: 3),
                    );
                  }
                },
              ),
            );
          }
        }

        print("Created ${newFieldPoints.length} field point markers");
        _fieldPoints = newFieldPoints;
        notifyListeners();
      }
    } catch (e) {
      print("Error processing field points data: $e");
    }
  }

  Future<void> fetchSiteBoundary() async {
    if (_isLoadingSiteBoundary) return; // Prevent multiple concurrent calls
    
    _isLoadingSiteBoundary = true;
    notifyListeners();
    
    const String boundaryUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/boundary.geojson";

    try {
      print("Fetching site boundary from: $boundaryUrl");
      final response = await http.get(Uri.parse(boundaryUrl));

      if (response.statusCode == 200) {
        print("Site boundary data received, length: ${response.body.length}");
        Map<String, dynamic> jsonData = json.decode(response.body);
        print("Site boundary JSON parsed: ${jsonData['type']}");

        if (jsonData['type'] == 'FeatureCollection' && jsonData['features'] is List) {
          Set<Polygon> newPolygons = {};
          List<dynamic> features = jsonData['features'];
          print("Number of features: ${features.length}");

          for (var feature in features) {
            if (feature['geometry'] != null && 
                feature['geometry']['type'] == 'Polygon' && 
                feature['geometry']['coordinates'] != null) {
              
              List<dynamic> coordinates = feature['geometry']['coordinates'];
              print("Processing polygon with ${coordinates.length} coordinate sets");
              
              // Since this is a single polygon, we take the first element
              List<dynamic> polygonCoordinates = coordinates[0];
              print("Number of polygon points: ${polygonCoordinates.length}");

              List<LatLng> polygonPoints = [];
              for (var point in polygonCoordinates) {
                if (point is List && point.length >= 2) {
                  // GeoJSON format is [longitude, latitude]
                  double lng = point[0].toDouble();
                  double lat = point[1].toDouble();
                  polygonPoints.add(LatLng(lat, lng));
                }
              }

              if (polygonPoints.length > 2) { // Need at least 3 points for a valid polygon
                print("Creating polygon with ${polygonPoints.length} points");
                String polygonId = 'site_boundary_${feature['properties']?['park_id'] ?? DateTime.now().millisecondsSinceEpoch}';
                
                newPolygons.add(
                  Polygon(
                    polygonId: PolygonId(polygonId),
                    points: polygonPoints,
                    strokeWidth: 3,
                    strokeColor: Colors.deepPurple,
                    fillColor: Colors.deepPurple.withOpacity(0.3),
                  ),
                );
              } else {
                print("Not enough points for a valid polygon: ${polygonPoints.length}");
              }
            }
          }

          print("Created ${newPolygons.length} site boundary polygons");
          _polygonsSite = newPolygons;
          notifyListeners();
        }
      } else {
        print("Failed to fetch site boundary. Status code: ${response.statusCode}");
        throw Exception("Failed to load site boundary: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching site boundary: $e");
    } finally {
      _isLoadingSiteBoundary = false;
      notifyListeners();
    }
  }

  Future<void> fetchPolygonsFromGeoServer() async {
    const String geoServerUrl =
        "https://agrex-demo.farmwiseai.com/geoserver/Puvi/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Puvi:district_boundary&outputFormat=application/json";

    try {
      final response = await http.get(Uri.parse(geoServerUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        PolygonModel polygonData = PolygonModel.fromGeoJson(jsonData);

        Set<Polygon> fetchedPolygons = {};
        Set<Marker> fetchedMarkers = {}; // Added

        for (int i = 0; i < polygonData.features.length; i++) {
          var feature = polygonData.features[i];
          var coordinates = feature.geometry.coordinates;
          var distName = feature.properties.distName;
          // Convert coordinates to LatLng
          List<LatLng> polygonPoints =
              coordinates[0][0]
                  .map((point) => LatLng(point[1], point[0]))
                  .toList();

          LatLng labelPosition = _findLabelPosition(polygonPoints);

          fetchedPolygons.add(
            Polygon(
              polygonId: PolygonId('polygon_$i'),
              points: polygonPoints,
              strokeWidth: 2,
              strokeColor: Colors.blue,
              fillColor: Colors.blue.withOpacity(0.3),
            ),
          );

          BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
            distName,
          );
          // Add marker with custom icon
          fetchedMarkers.add(
            Marker(
              markerId: MarkerId('marker_$i'),
              position: labelPosition,
              icon: customIcon,
              infoWindow: InfoWindow(title: distName),
            ),
          );
        }

        _polygons = fetchedPolygons;
        _markers = fetchedMarkers;
        notifyListeners();
      } else {
        throw Exception("Failed to load polygons");
      }
    } catch (e) {
      print("Error fetching polygons: $e");
    }
  }

  LatLng _findLabelPosition(List<LatLng> polygon) {
    List<turf.Position> positions =
        polygon
            .map((point) => turf.Position(point.longitude, point.latitude))
            .toList();

    // Create a Polygon feature
    turf.Feature<turf.Polygon> polygonFeature = turf.Feature<turf.Polygon>(
      geometry: turf.Polygon(coordinates: [positions]),
    );

    // Calculate the centroid
    turf.Feature<turf.Point> centroidFeature = turf.centroid(polygonFeature);

    // Check if the centroid is inside the polygon
    if (turf.booleanPointInPolygon(
      centroidFeature.geometry!.coordinates,
      polygonFeature,
    )) {
      return LatLng(
        centroidFeature.geometry!.coordinates.lat.toDouble(),
        centroidFeature.geometry!.coordinates.lng.toDouble(),
      );
    }

    // If centroid is outside, return the midpoint of the first segment
    return LatLng(
      (polygon[0].latitude + polygon[1].latitude) / 2,
      (polygon[0].longitude + polygon[1].longitude) / 2,
    );
  }
}