import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonModel {
  List<List<LatLng>> coordinates = [];

  PolygonModel.fromGeoJson(Map<String, dynamic> geoJson) {
    var features = geoJson['features'] as List;
    for (var feature in features) {
      var geometry = feature['geometry'];
      if (geometry['type'] == 'MultiPolygon') {
        var coords = geometry['coordinates'] as List;
        for (var polygon in coords) {
          for (var ring in polygon) {
            List<LatLng> points = [];
            for (var point in ring) {
              // Ensure each point is a List<double>
              if (point is List && point.length == 2) {
                double longitude = point[0] as double;
                double latitude = point[1] as double;
                points.add(LatLng(latitude, longitude));
              } else {
                throw FormatException("Invalid point format: $point");
              }
            }
            coordinates.add(points);
          }
        }
      }
    }
  }
}
