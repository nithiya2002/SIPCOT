import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sipcot/model/polygon_model.dart';
import 'package:sipcot/utility/create_custom_icon.dart';
import 'package:turf/turf.dart' as turf;

class MapViewModel extends ChangeNotifier {
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};

  Set<Polygon> get polygons => _polygons;
  Set<Marker> get markers => _markers; // Added

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

          // Create custom icon for the district name
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
