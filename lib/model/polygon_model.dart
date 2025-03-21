import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonModel {
  List<Feature> features = [];

  PolygonModel.fromGeoJson(Map<String, dynamic> json) {
    if (json['features'] != null) {
      features =
          (json['features'] as List)
              .map((feature) => Feature.fromJson(feature))
              .toList();
    }
  }
}

class Feature {
  String type;
  String id;
  Geometry geometry;
  Properties properties;

  Feature.fromJson(Map<String, dynamic> json)
    : type = json['type'],
      id = json['id'],
      geometry = Geometry.fromJson(json['geometry']),
      properties = Properties.fromJson(json['properties']);
}

class Geometry {
  String type;
  List<List<List<List<double>>>> coordinates;

  Geometry.fromJson(Map<String, dynamic> json)
    : type = json['type'],
      coordinates =
          (json['coordinates'] as List)
              .map(
                (polygon) =>
                    (polygon as List)
                        .map(
                          (ring) =>
                              (ring as List)
                                  .map(
                                    (point) => (point as List).cast<double>(),
                                  )
                                  .toList(),
                        )
                        .toList(),
              )
              .toList();

  List<List<LatLng>> toLatLng() {
    List<List<LatLng>> latLngList = [];
    for (var polygon in coordinates) {
      for (var ring in polygon) {
        List<LatLng> points = [];
        for (var point in ring) {
          if (point.length == 2) {
            double longitude = point[0];
            double latitude = point[1];
            points.add(LatLng(latitude, longitude));
          }
        }
        latLngList.add(points);
      }
    }
    return latLngList;
  }
}

class Properties {
  String distName;
  int districtCode;

  Properties.fromJson(Map<String, dynamic> json)
    : distName = json['dist_name'],
      districtCode = json['district_c'];
}


// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PolygonModel {
  // List<List<LatLng>> coordinates = [];

  // PolygonModel.fromGeoJson(Map<String, dynamic> geoJson) {
  //   var features = geoJson['features'] as List;
  //   for (var feature in features) {
  //     var geometry = feature['geometry'];
  //     if (geometry['type'] == 'MultiPolygon') {
  //       var coords = geometry['coordinates'] as List;
  //       for (var polygon in coords) {
  //         for (var ring in polygon) {
  //           List<LatLng> points = [];
  //           for (var point in ring) {
  //             // Ensure each point is a List<double>
  //             if (point is List && point.length == 2) {
  //               double longitude = point[0] as double;
  //               double latitude = point[1] as double;
  //               points.add(LatLng(latitude, longitude));
  //             } else {
  //               throw FormatException("Invalid point format: $point");
  //             }
  //           }
  //           coordinates.add(points);
  //         }
  //       }
  //     }
  //   }
  // }

//   List<List<LatLng>> coordinates = [];

//   PolygonModel.fromGeoJson(Map<String, dynamic> geoJson) {
//     var features = geoJson['features'] as List;
//     for (var feature in features) {
//       var geometry = feature['geometry'];
//       if (geometry['type'] == 'MultiPolygon') {
//         var coords = geometry['coordinates'] as List;
//         for (var polygon in coords) {
//           List<LatLng> points = [];
//           for (var ring in polygon) {
//             for (var point in ring) {
//               if (point is List && point.length == 2) {
//                 double longitude = point[0] as double;
//                 double latitude = point[1] as double;
//                 points.add(LatLng(latitude, longitude));
//               } else {
//                 throw FormatException("Invalid point format: $point");
//               }
//             }
//             coordinates.add(points);
//           }
//         }
//       }
//     }
//   }
// }
