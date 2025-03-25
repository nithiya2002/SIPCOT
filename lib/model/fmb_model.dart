import 'package:google_maps_flutter/google_maps_flutter.dart';

class FMBModel {
  String type;
  String name;
  Crs crs;
  List<Feature> features;

  FMBModel({
    required this.type,
    required this.name,
    required this.crs,
    required this.features,
  });

  factory FMBModel.fromJson(Map<String, dynamic> json) => FMBModel(
    type: json["type"],
    name: json["name"],
    crs: Crs.fromJson(json["crs"]),
    features: List<Feature>.from(
      json["features"].map((x) => Feature.fromJson(x)),
    ),
  );

  factory FMBModel.fromGeoJson(Map<String, dynamic> json) {
    return FMBModel.fromJson(json);
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "name": name,
    "crs": crs.toJson(),
    "features": List<dynamic>.from(features.map((x) => x.toJson())),
  };
}

class Crs {
  String type;
  CrsProperties properties;

  Crs({required this.type, required this.properties});

  factory Crs.fromJson(Map<String, dynamic> json) => Crs(
    type: json["type"],
    properties: CrsProperties.fromJson(json["properties"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "properties": properties.toJson(),
  };
}

class CrsProperties {
  String name;

  CrsProperties({required this.name});

  factory CrsProperties.fromJson(Map<String, dynamic> json) =>
      CrsProperties(name: json["name"]);

  Map<String, dynamic> toJson() => {"name": name};
}

class Feature {
  String type;
  Properties properties;
  Geometry geometry;

  Feature({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    type: json["type"],
    properties: Properties.fromJson(json["properties"]),
    geometry: Geometry.fromJson(json["geometry"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "properties": properties.toJson(),
    "geometry": geometry.toJson(),
  };
}

class Geometry {
  String type;
  List<List<List<List<double>>>> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json["type"],
    coordinates: List<List<List<List<double>>>>.from(
      json["coordinates"].map(
        (x) => List<List<List<double>>>.from(
          x.map(
            (x) => List<List<double>>.from(
              x.map((x) => List<double>.from(x.map((x) => x.toDouble()))),
            ),
          ),
        ),
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(
      coordinates.map(
        (x) => List<dynamic>.from(
          x.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x)))),
        ),
      ),
    ),
  };

  List<List<LatLng>> toLatLngLists() {
    List<List<LatLng>> polygonPoints = [];
    for (var polygon in coordinates) {
      for (var ring in polygon) {
        polygonPoints.add(
          ring.map<LatLng>((point) => LatLng(point[1], point[0])).toList(),
        );
      }
    }
    return polygonPoints;
  }
}

class Properties {
  String kide;
  int landId;
  int surveyNumber;
  String subdivisionNumber;
  String reginetLandClassification;
  int tamilnilamPattaNumber;
  String tamilnilamGovernmentPriority;
  String tamilnilamOwnerDetails;
  String rabiCropClassification;
  String rabiCropName;
  double rabiArea;
  String baseUid;
  String parkName;

  Properties({
    required this.kide,
    required this.landId,
    required this.surveyNumber,
    required this.subdivisionNumber,
    required this.reginetLandClassification,
    required this.tamilnilamPattaNumber,
    required this.tamilnilamGovernmentPriority,
    required this.tamilnilamOwnerDetails,
    required this.rabiCropClassification,
    required this.rabiCropName,
    required this.rabiArea,
    required this.baseUid,
    required this.parkName,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    kide: json["KIDE"] ?? "",
    landId: json["land_id"],
    surveyNumber: json["Survey Number"] ?? 0,
    subdivisionNumber: json["Subdivision Number"] ?? "-",
    reginetLandClassification: json["reginet_Land_Classification"] ?? "",
    tamilnilamPattaNumber: json["tamilnilam_patta_number"] ?? 0,
    tamilnilamGovernmentPriority: json["tamilnilam_government_priority"] ?? "",
    tamilnilamOwnerDetails: json["tamilnilam_owner_details"] ?? "",
    rabiCropClassification: json["rabi_crop_classification"] ?? "",
    rabiCropName: json["rabi_crop_name"] ?? "",
    rabiArea: json["rabi_area"]?.toDouble() ?? 0.0,
    baseUid: json["base_uid"]?.toString() ?? "",
    parkName: json["Park_name"]?.toString() ?? "", // Corrected line
  );

  Map<String, dynamic> toJson() => {
    "KIDE": kide,
    "land_id": landId,
    "Survey Number": surveyNumber,
    "Subdivision Number": subdivisionNumber,
    "reginet_Land_Classification": reginetLandClassification,
    "tamilnilam_patta_number": tamilnilamPattaNumber,
    "tamilnilam_government_priority": tamilnilamGovernmentPriority,
    "tamilnilam_owner_details": tamilnilamOwnerDetails,
    "rabi_crop_classification": rabiCropClassification,
    "rabi_crop_name": rabiCropName,
    "rabi_area": rabiArea,
    "base_uid": baseUid,
    "Park_name": parkName,
  };
}
