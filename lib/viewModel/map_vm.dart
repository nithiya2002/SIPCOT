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
  

  Set<Polygon> get polygons => _polygons;
  Set<Polygon> get polygonsSite => _showSiteBoundary ? _polygonsSite : {};
   bool get showSiteBoundary => _showSiteBoundary;

  Set<Marker> get markers => _markers; // Added
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
      // First try to load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('field_points_data');
      
      Map<String, dynamic> jsonData;
      
      if (savedData == null) {
        // If no saved data, fetch from API
        final response = await http.get(Uri.parse('https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/field_points.geojson'));
        
        if (response.statusCode == 200) {
          // Save to SharedPreferences for offline use
          await prefs.setString('field_points_data', response.body);
          jsonData = json.decode(response.body);
        } else {
          throw Exception("Failed to load field points");
        }
      } else {
        // Use the saved data
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
      // Check if it's a valid GeoJSON FeatureCollection
      if (jsonData['type'] == 'FeatureCollection' &&
          jsonData['features'] is List) {
        Set<Marker> newFieldPoints = {};
        List features = jsonData['features'];

        for (int i = 0; i < features.length; i++) {
          var feature = features[i];
          var properties = feature['properties'];
          var geometry = feature['geometry'];

          void navigateToMediaScreen(
            
            Map<String, dynamic> properties,
          ) {
            List<String> mediaUrls = [];

            // Collect all available images and videos
            for (int i = 1; i <= 4; i++) {
              if (properties["image_$i"] != null) {
                mediaUrls.add(properties["image_$i"]);
              }
            }
            if (properties["video_1"] != null)
              mediaUrls.add(properties["video_1"]);
            if (properties["video_2"] != null)
              mediaUrls.add(properties["video_2"]);

            // Navigate to the media preview screen
           Get.to(MediaPreviewScreen(mediaUrls: mediaUrls));
          }

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
          newFieldPoints.add(
  Marker(
    markerId: MarkerId('field_point_$pointId'),
    position: position,
    icon: markerIcon,
    // Make InfoWindow visible by default
    // infoWindow: InfoWindow(
    //   title: "Point $pointId",
    //   snippet: parkName,
    // ),
    onTap: () {
      // Create media URLs list
      List<String> mediaUrls = [];
      
      // Collect all available images and videos
      for (int i = 1; i <= 4; i++) {
        if (properties["image_$i"] != null) {
          mediaUrls.add(properties["image_$i"]);
        }
      }
      if (properties["video_1"] != null)
        mediaUrls.add(properties["video_1"]);
      if (properties["video_2"] != null)
        mediaUrls.add(properties["video_2"]);



      // Use Get.to() with a function parameter
      Get.to(() => MediaPreviewScreen(mediaUrls: mediaUrls));
    },
  ),
);
          }
        }

        _fieldPoints = newFieldPoints;
        notifyListeners();
      }
    } catch (e) {
      print("Error processing field points data: $e");
    }
  }


Future<void> fetchSiteBoundary() async {
  const String boundaryUrl =
      "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/boundary.geojson";

  try {
    final response = await http.get(Uri.parse(boundaryUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['type'] == 'FeatureCollection' && jsonData['features'] is List) {
        Set<Polygon> newPolygons = {};

        for (var feature in jsonData['features']) {
          if (feature['geometry']['type'] == 'Polygon') {
            List<dynamic> coordinates = feature['geometry']['coordinates'];
                  
            // Since this is a single polygon, we take the first element
            List<List<dynamic>> polygonCoordinates = coordinates[0];

            List<LatLng> polygonPoints = polygonCoordinates
                .map((point) => LatLng(point[1] as double, point[0] as double)) // Ignore altitude
                .toList();

            newPolygons.add(
              Polygon(
                polygonId: PolygonId(feature['properties']['park_id'].toString()),
                points: polygonPoints,
                strokeWidth: 2,
                strokeColor: Colors.deepPurple,
                fillColor: Colors.deepPurple.withOpacity(0.3),
              ),
            );
          }
        }

        _polygonsSite = newPolygons;
        notifyListeners();
      }
    } else {
      throw Exception("Failed to load site boundary");
    }
  } catch (e) {
    print("Error fetching site boundary: $e");
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
