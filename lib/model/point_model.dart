class FieldPointsModel {
  final String type;
  final String name;
  final Map<String, dynamic> crs;
  final List<FieldPoint> features;

  FieldPointsModel({
    required this.type,
    required this.name,
    required this.crs,
    required this.features,
  });

  factory FieldPointsModel.fromJson(Map<String, dynamic> json) {
    return FieldPointsModel(
      type: json['type'],
      name: json['name'],
      crs: json['crs'],
      features:
          (json['features'] as List)
              .map((feature) => FieldPoint.fromJson(feature))
              .toList(),
    );
  }
}

class FieldPoint {
  final String type;
  final FieldPointProperties properties;
  final FieldPointGeometry geometry;

  FieldPoint({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory FieldPoint.fromJson(Map<String, dynamic> json) {
    return FieldPoint(
      type: json['type'],
      properties: FieldPointProperties.fromJson(json['properties']),
      geometry: FieldPointGeometry.fromJson(json['geometry']),
    );
  }
}

class FieldPointProperties {
  final int pointId;
  final double lat;
  final double long;
  final String parkName;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? image4;
  final String? video1;
  final String? video2;
  final int parkId;
  final String classification;

  FieldPointProperties({
    required this.pointId,
    required this.lat,
    required this.long,
    required this.parkName,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.video1,
    this.video2,
    required this.parkId,
    required this.classification,
  });

  factory FieldPointProperties.fromJson(Map<String, dynamic> json) {
    return FieldPointProperties(
      pointId: json['point_id'],
      lat: json['Lat'].toDouble(),
      long: json['Long'].toDouble(),
      parkName: json['Park_name'],
      image1: json['image_1'],
      image2: json['image_2'],
      image3: json['image_3'],
      image4: json['image_4'],
      video1: json['video_1'],
      video2: json['video_2'],
      parkId: json['park_id'],
      classification: json['classification'],
    );
  }
}

class FieldPointGeometry {
  final String type;
  final List<double> coordinates;

  FieldPointGeometry({required this.type, required this.coordinates});

  factory FieldPointGeometry.fromJson(Map<String, dynamic> json) {
    return FieldPointGeometry(
      type: json['type'],
      coordinates: (json['coordinates'] as List).cast<double>(),
    );
  }
}
