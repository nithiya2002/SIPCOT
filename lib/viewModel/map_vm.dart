// map_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sipcot/model/polygon_model.dart';
import 'package:sipcot/model/cadastral_model.dart'; // Import CadastralModel
import 'package:sipcot/utility/create_custom_icon.dart';
import 'package:sipcot/utility/custom_logger.dart';
import 'package:turf/turf.dart' as turf;

class MapViewModel extends ChangeNotifier {
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _cadastralData = [];

  Set<Polygon> get polygons => _polygons;
  Set<Marker> get markers => _markers;
  List<Map<String, dynamic>> get cadastralData => _cadastralData;

  final log = createLogger(MapViewModel);

  void clearMap() {
    _polygons.clear();
    _markers.clear();
    notifyListeners();
  }

  void updateMap(Set<Polygon> polygons, Set<Marker> markers) {
    _polygons = polygons;
    _markers = markers;
    notifyListeners();
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
        Set<Marker> fetchedMarkers = {};

        for (int i = 0; i < polygonData.features.length; i++) {
          var feature = polygonData.features[i];
          var coordinates = feature.geometry.coordinates;
          var distName = feature.properties.distName;
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
              consumeTapEvents: true,
              onTap: () {
                _onDistrictSelected(distName);
              },
            ),
          );
          BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
            distName,
          );
          fetchedMarkers.add(
            Marker(
              markerId: MarkerId('marker_$i'),
              position: labelPosition,
              icon: customIcon,
              infoWindow: InfoWindow(title: distName),
              consumeTapEvents: true,
              onTap: () {
                _onDistrictSelected(distName);
              },
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
      log.e("Error fetching polygons: $e");
    }
  }

  LatLng _findLabelPosition(List<LatLng> polygon) {
    List<turf.Position> positions =
        polygon
            .map((point) => turf.Position(point.longitude, point.latitude))
            .toList();
    turf.Feature<turf.Polygon> polygonFeature = turf.Feature<turf.Polygon>(
      geometry: turf.Polygon(coordinates: [positions]),
    );
    turf.Feature<turf.Point> centroidFeature = turf.centroid(polygonFeature);
    if (turf.booleanPointInPolygon(
      centroidFeature.geometry!.coordinates,
      polygonFeature,
    )) {
      return LatLng(
        centroidFeature.geometry!.coordinates.lat.toDouble(),
        centroidFeature.geometry!.coordinates.lng.toDouble(),
      );
    }
    return LatLng(
      (polygon[0].latitude + polygon[1].latitude) / 2,
      (polygon[0].longitude + polygon[1].longitude) / 2,
    );
  }

  void _onDistrictSelected(String districtName) async {
    log.i("District selected: $districtName");
    if (districtName == "Tiruppur") {
      await _fetchCadastralData(districtName);
    }
  }

  Future<void> _fetchCadastralData(String districtName) async {
    const String cadastralUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/cadastral.geojson";
    try {
      final response = await http.get(Uri.parse(cadastralUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        //  _cadastralData = _parseCadastralData(jsonData);
        _updateMapWithCadastralData(jsonData);
      } else {
        throw Exception("Failed to load cadastral data");
      }
    } catch (e) {
      log.e("Error fetching cadastral data: $e");
    }
  }

  void _updateMapWithCadastralData(Map<String, dynamic> jsonData) async {
    _polygons.clear();
    _markers.clear();
    Set<Polygon> cadastralPolygons = {};
    Set<Marker> cadastralMarkers = {};

    var features = jsonData['features'];
    for (int i = 0; i < features.length; i++) {
      var feature = features[i];
      var coordinates = feature['geometry']['coordinates'];
      var properties = feature['properties']; // Define properties here

      // Handle MultiPolygon coordinates
      if (feature['geometry']['type'] == 'MultiPolygon') {
        for (var polygon in coordinates) {
          for (var ring in polygon) {
            // Convert coordinates to LatLng
            List<LatLng> polygonPoints =
                ring.map<LatLng>((point) {
                  return LatLng(point[1], point[0]);
                }).toList();

            // Add cadastral polygon
            cadastralPolygons.add(
              Polygon(
                polygonId: PolygonId('cadastral_polygon_$i'),
                points: polygonPoints,
                strokeWidth: 2,
                strokeColor: Colors.green,
                fillColor: Colors.green.withOpacity(0.3),
              ),
            );

            // Create custom icon for the survey number
            BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
              properties['survey_no'].toString(), // Use properties here
            );

            // Add cadastral marker with custom icon
            cadastralMarkers.add(
              Marker(
                markerId: MarkerId('cadastral_marker_$i'),
                position:
                    polygonPoints[0], // Use the first point as the marker position
                icon: customIcon, // Set the custom icon
              ),
            );
          }
        }
      }
    }

    // Update the map
    _polygons = cadastralPolygons;
    _markers = cadastralMarkers;
    notifyListeners(); // Trigger UI update
  }
}
