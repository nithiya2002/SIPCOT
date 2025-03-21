import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sipcot/model/polygon_model.dart';
import 'package:sipcot/model/cadastral_model.dart';
import 'package:sipcot/utility/create_custom_icon.dart';
import 'package:sipcot/utility/custom_logger.dart';

class MapViewModel extends ChangeNotifier {
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  String? _selectedDistrict;

  Set<Polygon> get polygons => _polygons;
  Set<Marker> get markers => _markers;
  String? get selectedDistrict => _selectedDistrict;

  final log = createLogger(MapViewModel);

  void clearMap() {
    _polygons.clear();
    _markers.clear();
    _selectedDistrict = null;
    notifyListeners();
  }

  void updateMap(Set<Polygon> polygons, Set<Marker> markers) {
    _polygons = polygons;
    _markers = markers;
    notifyListeners();
  }

  Future<void> fetchPolygonData() async {
    final String wfsUrl =
        "https://agrex-demo.farmwiseai.com/geoserver/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Puvi:district_boundary&outputFormat=application/json";
    try {
      final response = await http.get(Uri.parse(wfsUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        _processPolygonData(jsonData);
      } else {
        throw Exception("Failed to load Polygon data");
      }
    } catch (e) {
      log.e("Error fetching Polygon data: $e");
    }
  }

  Future<void> fetchCadastralData(String selectedDistrict) async {
    final String wfsUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/cadastral.geojson";
    try {
      final response = await http.get(Uri.parse(wfsUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        _processCadastralData(jsonData);
      } else {
        throw Exception("Failed to load Cadastral data");
      }
    } catch (e) {
      log.e("Error fetching Cadastral data: $e");
    }
  }

  void _processPolygonData(Map<String, dynamic> jsonData) async {
    _polygons.clear();
    _markers.clear();
    Set<Polygon> fetchedPolygons = {};
    Set<Marker> fetchedMarkers = {};

    PolygonModel polygonData = PolygonModel.fromGeoJson(jsonData);
    /* for (int i = 0; i < polygonData.coordinates.length; i++) {
      List<LatLng> polygonPoints = polygonData.coordinates[i];
      fetchedPolygons.add(
        Polygon(
          polygonId: PolygonId('polygon_$i'),
          points: polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.3),
          consumeTapEvents: true,
          onTap: () {
            _onFeatureTap("SIPCOT"); // Pass distName
          },
        ),
      );

      LatLng labelPosition = _findLabelPosition(
        polygonPoints,
      ); // Find label position
      BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
        "SIPCOT",
      ); // create custom icon

      fetchedMarkers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: labelPosition,
          icon: customIcon,
          infoWindow: InfoWindow(title: "SIPCOT"),
          consumeTapEvents: true,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            _onFeatureTap("SIPCOT"); // Pass distName
          },
        ),
      );
    } */

    for (int i = 0; i < polygonData.features.length; i++) {
      var feature = polygonData.features[i];
      var coordinates = feature.geometry.coordinates;
      var properties = feature.properties;

      // for (var polygon in coordinates) {
      //   for (var ring in polygon) {
      // List<LatLng> polygonPoints =
      //     ring.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
      List<LatLng> polygonPoints =
          coordinates[0][0].map((point) => LatLng(point[1], point[0])).toList();
      fetchedPolygons.add(
        Polygon(
          polygonId: PolygonId('polygon_$i'),
          points: polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.3),
          consumeTapEvents: true,
          onTap: () {
            _onFeatureTap(properties.distName);
          },
        ),
      );

      LatLng labelPosition = _findLabelPosition(polygonPoints);
      String labelText = properties.distName;
      BitmapDescriptor customIcon = await MapUtils.createCustomIcon(labelText);

      fetchedMarkers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: labelPosition,
          icon: customIcon,
          infoWindow: InfoWindow(title: labelText),
          consumeTapEvents: true,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            _onFeatureTap(properties.distName);
          },
        ),
      );
      //   }
      // }
    }
    _polygons = fetchedPolygons;
    _markers = fetchedMarkers;
    notifyListeners();
  }

  void _processCadastralData(Map<String, dynamic> jsonData) async {
    _polygons.clear();
    _markers.clear();
    Set<Polygon> fetchedPolygons = {};
    Set<Marker> fetchedMarkers = {};

    CadastralModel cadastralData = CadastralModel.fromGeoJson(jsonData);

    for (int i = 0; i < cadastralData.features.length; i++) {
      var feature = cadastralData.features[i];
      var coordinates = feature.geometry.coordinates;
      var properties = feature.properties;
      if (coordinates.isNotEmpty) {
        for (var polygon in coordinates) {
          for (var ring in polygon) {
            List<LatLng> polygonPoints =
                ring
                    .map<LatLng>((point) => LatLng(point[1], point[0]))
                    .toList();
            fetchedPolygons.add(
              Polygon(
                polygonId: PolygonId('cadastral_polygon_$i'),
                points: polygonPoints,
                strokeWidth: 2,
                strokeColor: Colors.green,
                fillColor: Colors.green.withOpacity(0.3),
                consumeTapEvents: true,
                onTap: () {
                  _onFeatureTap(properties.surveyNo);
                },
              ),
            );

            // Create a marker for the polygon.
            LatLng labelPosition = _findLabelPosition(polygonPoints);
            String labelText = properties.surveyNo;
            BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
              labelText,
            );
            fetchedMarkers.add(
              Marker(
                markerId: MarkerId('cadastral_marker_$i'),
                position: labelPosition,
                icon: customIcon,
                infoWindow: InfoWindow(title: labelText),
                consumeTapEvents: true,
                anchor: const Offset(0.5, 0.5),
                onTap: () {
                  _onFeatureTap(properties.surveyNo);
                },
              ),
            );
          }
        }
      }
    }

    _polygons = fetchedPolygons;
    _markers = fetchedMarkers;
    notifyListeners();
  }

  LatLng _findLabelPosition(List<LatLng> polygon) {
    // Your implementation to find the label position (e.g., centroid)
    if (polygon.isEmpty) return const LatLng(0, 0); // handle empty polygon
    double lat = 0, lng = 0;
    for (var point in polygon) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / polygon.length, lng / polygon.length);
  }
  // LatLng _findLabelPosition(List<LatLng> polygon) {
  //   List<turf.Position> positions =
  //       polygon
  //           .map((point) => turf.Position(point.longitude, point.latitude))
  //           .toList();
  //   turf.Feature<turf.Polygon> polygonFeature = turf.Feature<turf.Polygon>(
  //     geometry: turf.Polygon(coordinates: [positions]),
  //   );
  //   turf.Feature<turf.Point> centroidFeature = turf.centroid(polygonFeature);
  //   if (turf.booleanPointInPolygon(
  //     centroidFeature.geometry!.coordinates,
  //     polygonFeature,
  //   )) {
  //     return LatLng(
  //       centroidFeature.geometry!.coordinates.lat.toDouble(),
  //       centroidFeature.geometry!.coordinates.lng.toDouble(),
  //     );
  //   }
  //   return LatLng(
  //     (polygon[0].latitude + polygon[1].latitude) / 2,
  //     (polygon[0].longitude + polygon[1].longitude) / 2,
  //   );
  // }

  void _onFeatureTap(String properties) async {
    log.i('properties value, $properties');
    if (_selectedDistrict == null) {
      _selectedDistrict = properties;
      await fetchCadastralData(properties);
    } else {
      _selectedDistrict = null;
      fetchPolygonData();
    }
  }
}
