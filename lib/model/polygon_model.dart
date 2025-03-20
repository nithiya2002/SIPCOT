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
}

class Properties {
  String distName;
  int districtCode;

  Properties.fromJson(Map<String, dynamic> json)
    : distName = json['dist_name'],
      districtCode = json['district_c'];
}
