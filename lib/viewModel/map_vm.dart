import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sipcot/model/fmb_model.dart';
import 'package:sipcot/model/polygon_model.dart';
import 'package:sipcot/model/cadastral_model.dart';
import 'package:sipcot/utility/create_custom_icon.dart';
import 'package:sipcot/utility/custom_logger.dart';
import 'dart:async'; // Add this import for Timer
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:sipcot/view/MediaScreen/mediaPreviewScreen.dart';

class MapViewModel extends ChangeNotifier {
  VoidCallback? onNavigateToDetails;

  Set<Polygon> _polygons = {};
  Set<Polygon> _polygonsSite = {};
  Set<Polygon> _newBoundaryPolygons = {};
  Set<Polygon> _polygon_cascade = {};
  Set<Marker> _markers = {};
  Set<Marker> _cascade_markers = {};
  String? _selectedDistrict;

  Set<Polygon> get polygons => _polygons;
  Set<Marker> get markers => _markers;
  Set<Marker> get cascadeMakers => _showCascadeBoundary ? _cascade_markers : {};
  String? get selectedDistrict => _selectedDistrict;
  Timer? _animationTimer;
  final bool _showDashedBoundary = true;
  bool _isAnimating = false;
  final List<Color> _animationColors = [
    Colors.orange.withOpacity(0.4),
    Colors.amber.withOpacity(0.6),
    Colors.yellow.withOpacity(0.8),
    Colors.amber.withOpacity(0.6),
  ];
  int _currentColorIndex = 0;
  Set<Marker> _fieldPoints = {};
  Set<Marker> _addedFieldPoints = {};
  bool _showFieldPoints = true;
  bool _addFieldPoints = true;
  bool _showSiteBoundary = true;
  bool _showCascadeBoundary = true;
  bool _showNewBoundary = true; // Add this for new boundary toggle
  bool _isLoadingSiteBoundary = false;
  bool _isLoadingNewBoundary = false; // Add this for loading state
  bool _isLoadingCascade = false;
  final log = createLogger(MapViewModel);
  Set<Polygon> get polygonsSite => _showSiteBoundary ? _polygonsSite : {};
  Set<Polygon> get newBoundaryPolygons =>
      _showNewBoundary && _showDashedBoundary ? _newBoundaryPolygons : {};
  Set<Polygon> get cascadeBoundaryPolygons =>
      _showCascadeBoundary ? _polygon_cascade : {};

  bool get showSiteBoundary => _showSiteBoundary;
  bool get isLoadingSiteBoundary => _isLoadingSiteBoundary;
  bool get showNewBoundary => _showNewBoundary;
  bool get showCascadeBoundary => _showCascadeBoundary;
  bool get isLoadingNewBoundary => _isLoadingNewBoundary;
  bool get isAnimating => _isAnimating;
  Set<Marker> get addFieldPoint => _addFieldPoints ? _addedFieldPoints : {};
  bool get showAddedFieldPoint => _addFieldPoints;
  Set<Marker> get fieldPoints => _showFieldPoints ? _fieldPoints : {};
  bool get showFieldPoints => _showFieldPoints;

  // MARK: FMB Map
  Set<Polygon> _fmb_polygon = {};
  Set<Marker> _fmb_marker = {};
  bool _showFmbBoundary = true;
  Set<Marker> get fmb_marker => _showFmbBoundary ? _fmb_marker : {};
  bool _isLoadingFMB = false;
  Set<Polygon> get fmbBoundaryPolygon => _showFmbBoundary ? _fmb_polygon : {};
  bool get showFmbBoundary => _showFmbBoundary;

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

  Future<void> fetchFMBData(String selectedDistrict) async {
    if (_isLoadingFMB) return;
    _isLoadingFMB = true;
    notifyListeners();

    final String wfsUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/fmb.geojson"; // Replace with your FMB data URL

    try {
      final response = await http.get(Uri.parse(wfsUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        _processFMBData(jsonData);
      } else {
        throw Exception("Failed to load FMB data");
      }
    } catch (e) {
      log.e("Error fetching FMB data: $e");
    } finally {
      _isLoadingFMB = false;
      notifyListeners();
    }
  }

  void _processFMBData(Map<String, dynamic> jsonData) async {
    Set<Polygon> fetchedPolygons = {};
    Set<Marker> fetchedMarkers = {};

    FMBModel fmbData = FMBModel.fromGeoJson(jsonData); // Use your FMB model

    for (int i = 0; i < fmbData.features.length; i++) {
      var feature = fmbData.features[i];
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
                polygonId: PolygonId('fmb_polygon_$i'),
                points: polygonPoints,
                strokeWidth: 2,
                strokeColor: Colors.black, // Customize color if needed
                fillColor: Colors.blue.withOpacity(
                  0.3,
                ), // Customize color if needed
                consumeTapEvents: true,
              ),
            );

            // Create a marker for the polygon.
            LatLng labelPosition = _findLabelPosition(polygonPoints);
            String labelText = properties.kide;
            BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
              labelText,
              Colors.black,
            );

            if (_showFmbBoundary) {
              fetchedMarkers.add(
                Marker(
                  markerId: MarkerId('fmb_marker_$i'),
                  position: labelPosition,
                  icon: customIcon,
                  infoWindow: InfoWindow(title: labelText),
                  consumeTapEvents: true,
                  anchor: const Offset(0.5, 0.5),
                  onTap: () {
                    log.i("44444 ---------- ");
                    _onFeatureTap(properties.kide);
                  },
                ),
              );
            }
          }
        }
      }
    }

    _fmb_polygon = fetchedPolygons;
    _fmb_marker = fetchedMarkers;
    notifyListeners();
  }

  Future<void> fetchCadastralData(String selectedDistrict) async {
    if (_isLoadingCascade) return;
    _isLoadingCascade = true;
    notifyListeners();

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
    } finally {
      _isLoadingCascade = false;
      notifyListeners();
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
      BitmapDescriptor customIcon = await MapUtils.createCustomIcon(
        labelText,
        Colors.white,
      );

      fetchedMarkers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: labelPosition,
          icon: customIcon,
          infoWindow: InfoWindow(title: labelText),
          consumeTapEvents: true,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            log.i("111111 ---------- ");
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
  Future<void> addNewFieldPoint({
    required LatLng location,
    required String surveyNumber,
    String? additionalDetails,
  }) async {
    try {
      // Create a marker icon based on the type (you can modify this logic)
      BitmapDescriptor markerIcon = await MapUtils.getTriangleMarker(Colors.blue);

      // Create a new marker
      Marker newMarker = Marker(
        markerId: MarkerId('new_field_point_$surveyNumber'),
        position: location,
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: 'Survey: $surveyNumber',
          snippet: additionalDetails ?? '',
        ),
        onTap: () {
          // Optional: Add functionality when the marker is tapped
          // For now, you can leave this empty or add a snackbar with details
          Get.snackbar(
            'Field Point Details',
            'Survey Number: $surveyNumber\n${additionalDetails ?? ''}',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );

      // Add the new marker to the field points
      _fieldPoints.add(newMarker);

      // Notify listeners to update the UI
      notifyListeners();

      // Optional: You might want to save this point to a persistent storage
      // For example, you could use SharedPreferences or a local database
      // This part depends on your specific requirements
    } catch (e) {
      log.e("Error adding new field point: $e");
    }
  }

  List<dynamic> getSurveySuggestions() {
    // Extract survey numbers from the cadastral data
    Set<dynamic> surveyNumbers = {};
    if (_polygon_cascade.isNotEmpty) {
      for (var polygon in _polygon_cascade) {
        // You'll need to modify this based on how your cadastral data is structured
        // This assumes that the survey number is accessible via the markers
        for (var marker in _cascade_markers) {
          surveyNumbers.add(marker.infoWindow.title);
        }
      }
    }
    return surveyNumbers.toList();
  }

  void _processCadastralData(Map<String, dynamic> jsonData) async {
    // _polygons.clear();
    // _markers.clear();
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
              Colors.green,
            );
            if (showCascadeBoundary) {
              fetchedMarkers.add(
                Marker(
                  markerId: MarkerId('cadastral_marker_$i'),
                  position: labelPosition,
                  icon: customIcon,
                  infoWindow: InfoWindow(title: labelText),
                  consumeTapEvents: true,
                  anchor: const Offset(0.5, 0.5),
                  onTap: () {
                    log.i("2222 ---------- ");
                    _onFeatureTap(properties.surveyNo);
                  },
                ),
              );
            }
          }
        }
      }
    }
    _polygon_cascade = fetchedPolygons;
    _cascade_markers = fetchedMarkers;
    notifyListeners();
  }

  LatLng _findLabelPosition(List<LatLng> polygon) {
    if (polygon.isEmpty) return const LatLng(0, 0); // handle empty polygon
    double lat = 0, lng = 0;
    for (var point in polygon) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / polygon.length, lng / polygon.length);
  }

  void _onFeatureTap(String properties) async {
    await fetchCadastralData(properties);
    // log.i('properties value, $properties');
    // if (_selectedDistrict == null) {
    //   _selectedDistrict = properties;
    //   await fetchCadastralData(properties);
    // } else {
    //   _selectedDistrict = null;
    //   fetchPolygonData();
    // }
  }

  void toggleFieldPoints(bool value) {
    _showFieldPoints = value;
    notifyListeners();
  }

  void toggleSiteBoundary(bool value) {
    _showSiteBoundary = value;
    notifyListeners();
  }

  void toggleNewBoundary(bool value) {
    _showNewBoundary = value;
    notifyListeners();
  }

  void toggleCascade(bool value) {
    _showCascadeBoundary = value;
    notifyListeners();
  }

  void toggleFMB(bool value) {
    _showFmbBoundary = value;
    notifyListeners();
  }

  void toggleAnimation(bool value) {
    _isAnimating = value;
    if (_isAnimating) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
    notifyListeners();
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _currentColorIndex = (_currentColorIndex + 1) % _animationColors.length;
      _updateDashedBoundaryColor();
    });
  }

  // Stop animation
  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  // Update the boundary color for animation effect
  void _updateDashedBoundaryColor() {
    if (_newBoundaryPolygons.isEmpty) return;
    Set<Polygon> updatedPolygons = {};
    for (var polygon in _newBoundaryPolygons) {
      updatedPolygons.add(
        Polygon(
          polygonId: polygon.polygonId,
          points: polygon.points,
          strokeWidth: 4,
          strokeColor: _animationColors[_currentColorIndex],
          fillColor: _animationColors[_currentColorIndex].withOpacity(0.2),
          // Make it dashed
          // patterns: [
          //   PatternItem.dash(20),
          //   PatternItem.gap(10),
          // ],
        ),
      );
    }
    _newBoundaryPolygons = updatedPolygons;
    notifyListeners();
  }

  Future<void> fetchNewBoundary() async {
    if (_isLoadingNewBoundary) return;
    _isLoadingNewBoundary = true;
    notifyListeners();
    const String newBoundaryUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/new_boundary.geojson";
    try {
      final response = await http.get(Uri.parse(newBoundaryUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['type'] == 'FeatureCollection' &&
            jsonData['features'] is List) {
          Set<Polygon> newPolygons = {};
          List<dynamic> features = jsonData['features'];
          for (var feature in features) {
            if (feature['geometry'] != null &&
                feature['geometry']['type'] == 'MultiPolygon' &&
                feature['geometry']['coordinates'] != null) {
              List<dynamic> multiPolygonCoordinates =
                  feature['geometry']['coordinates'];
              for (
                int polygonIndex = 0;
                polygonIndex < multiPolygonCoordinates.length;
                polygonIndex++
              ) {
                List<dynamic> polygonCoordinates =
                    multiPolygonCoordinates[polygonIndex][0];
                List<LatLng> polygonPoints = [];
                for (var point in polygonCoordinates) {
                  if (point is List && point.length >= 2) {
                    double lng = point[0].toDouble();
                    double lat = point[1].toDouble();
                    polygonPoints.add(LatLng(lat, lng));
                  }
                }
                if (polygonPoints.length > 2) {
                  String polygonId =
                      'new_boundary_${feature['properties']?['id'] ?? DateTime.now().millisecondsSinceEpoch}_$polygonIndex';
                  newPolygons.add(
                    Polygon(
                      polygonId: PolygonId(polygonId),
                      points: polygonPoints,
                      strokeWidth: 4,
                      strokeColor: Colors.white,
                      fillColor: Colors.white.withOpacity(0.3),
                      // Make it dashed
                      // patterns: [
                      //   PatternItem.dash(20),
                      //   PatternItem.gap(10),
                      // ],
                    ),
                  );
                } else {
                  log.i(
                    "Not enough points for a valid polygon: ${polygonPoints.length}",
                  );
                }
              }
            }
          }
          _newBoundaryPolygons = newPolygons;
          if (_isAnimating) {
            _startAnimation();
          }
          notifyListeners();
        }
      } else {
        throw Exception("Failed to load new boundary: ${response.statusCode}");
      }
    } catch (e) {
      log.e("Error fetching new boundary: $e");
    } finally {
      _isLoadingNewBoundary = false;
      notifyListeners();
    }
  }

  Future<void> fetchFieldPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('field_points_data');
      Map<String, dynamic> jsonData;
      if (savedData == null) {
        final response = await http.get(
          Uri.parse(
            'https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/field_points.geojson',
          ),
        );
        if (response.statusCode == 200) {
          await prefs.setString('field_points_data', response.body);
          jsonData = json.decode(response.body);
        } else {
          throw Exception(
            "Failed to load field points: ${response.statusCode}",
          );
        }
      } else {
        jsonData = json.decode(savedData);
      }
      await _processFieldPointsData(jsonData);
    } catch (e) {
      log.e("Error fetching field points: $e");
    }
  }

  Future<void> _processFieldPointsData(Map<String, dynamic> jsonData) async {
    try {
      if (jsonData['type'] == 'FeatureCollection' &&
          jsonData['features'] is List) {
        Set<Marker> newFieldPoints = {};
        List features = jsonData['features'];
        for (int i = 0; i < features.length; i++) {
          var feature = features[i];
          var properties = feature['properties'];
          var geometry = feature['geometry'];
          if (geometry['type'] == 'Point' && geometry['coordinates'] is List) {
            double longitude = geometry['coordinates'][0];
            double latitude = geometry['coordinates'][1];
            LatLng position = LatLng(latitude, longitude);
            int pointId = properties['point_id'];
            String parkName = properties['Park_name'] ?? 'Unknown';
            String classification = properties['classification'] ?? 'Unknown';
            BitmapDescriptor markerIcon = await MapUtils.getTriangleMarker(
              pointId % 2 == 0 ? Colors.green : Colors.red,
            );
            List<String> mediaUrls = [];
            for (int i = 1; i <= 4; i++) {
              if (properties["image_$i"] != null &&
                  properties["image_$i"].toString().isNotEmpty) {
                mediaUrls.add(properties["image_$i"]);
              }
            }
            if (properties["video_1"] != null &&
                properties["video_1"].toString().isNotEmpty) {
              mediaUrls.add(properties["video_1"]);
            }
            if (properties["video_2"] != null &&
                properties["video_2"].toString().isNotEmpty) {
              mediaUrls.add(properties["video_2"]);
            }
            newFieldPoints.add(
              Marker(
                markerId: MarkerId('field_point_$pointId'),
                position: position,
                icon: markerIcon,
                onTap: () {
                  log.i("3333 ---------- ");
                  // Navigate directly without using a closure
                  if (mediaUrls.isNotEmpty) {
                    Get.to(() => MediaPreviewScreen(point_id: pointId,Park_name: parkName,mediaUrls: mediaUrls));
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
        _fieldPoints = newFieldPoints;
        notifyListeners();
      }
    } catch (e) {
      log.e("Error processing field points data: $e");
    }
  }

  Future<void> fetchSiteBoundary() async {
    if (_isLoadingSiteBoundary) return; // Prevent multiple concurrent calls

    _isLoadingSiteBoundary = true;
    notifyListeners(); // Notify listeners to show loading state

    const String boundaryUrl =
        "https://main.d35889sospji4x.amplifyapp.com/sipcot/data/villages/site_1_kangeyam/boundary.geojson";

    try {
      final response = await http.get(Uri.parse(boundaryUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['type'] == 'FeatureCollection' &&
            jsonData['features'] is List) {
          Set<Polygon> newPolygons = {};
          List<dynamic> features = jsonData['features'];
          for (var feature in features) {
            if (feature['geometry'] != null &&
                feature['geometry']['type'] == 'Polygon' &&
                feature['geometry']['coordinates'] != null) {
              List<dynamic> coordinates = feature['geometry']['coordinates'];
              List<dynamic> polygonCoordinates = coordinates[0];
              List<LatLng> polygonPoints = [];
              for (var point in polygonCoordinates) {
                if (point is List && point.length >= 2) {
                  double lng = point[0].toDouble();
                  double lat = point[1].toDouble();
                  polygonPoints.add(LatLng(lat, lng));
                }
              }
              if (polygonPoints.length > 2) {
                String polygonId =
                    'site_boundary_${feature['properties']?['park_id'] ?? DateTime.now().millisecondsSinceEpoch}';
                newPolygons.add(
                  Polygon(
                    polygonId: PolygonId(polygonId),
                    points: polygonPoints,
                    strokeWidth: 3,
                    strokeColor: Colors.deepPurple,
                    fillColor: Colors.deepPurple.withOpacity(0.3),
                  ),
                );
              }
            }
          }
          _polygonsSite = newPolygons;
        }
      } else {
        throw Exception("Failed to load site boundary: ${response.statusCode}");
      }
    } catch (e) {
      log.e("Error fetching site boundary: $e");
    } finally {
      _isLoadingSiteBoundary = false;
      notifyListeners(); // Notify listeners after updating the state
    }
  }
}
