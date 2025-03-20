import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sipcot/utility/custom_logger.dart';

class CadastralModel {
  final String surveyNo;
  final List<List<LatLng>> polygons;
  final log = createLogger(CadastralModel);
  CadastralModel({required this.surveyNo, required this.polygons});
  factory CadastralModel.fromGeoJson(Map<String, dynamic> feature) {
    var properties = feature['properties'];
    var geometry = feature['geometry'];
    var coordinates = geometry['coordinates'];
    List<List<LatLng>> polygons = [];
    if (geometry['type'] == 'MultiPolygon') {
      for (var polygon in coordinates) {
        for (var ring in polygon) {
          List<LatLng> polygonPoints =
              ring.map<LatLng>((point) {
                return LatLng(point[1], point[0]);
              }).toList();
          polygons.add(polygonPoints);
        }
      }
    }
    return CadastralModel(
      surveyNo: properties['survey_no'],
      polygons: polygons,
    );
  }
}
