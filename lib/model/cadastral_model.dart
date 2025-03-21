class CadastralModel {
  List<CadastralFeature> features = [];

  CadastralModel.fromGeoJson(Map<String, dynamic> json) {
    if (json['features'] != null) {
      features =
          (json['features'] as List)
              .map((feature) => CadastralFeature.fromJson(feature))
              .toList();
    }
  }
}

class CadastralFeature {
  String type;
  String id;
  CadastralGeometry geometry;
  CadastralProperties properties;

  CadastralFeature.fromJson(Map<String, dynamic> json)
    : type = json['type'] ?? 'Unknown',
      id = json['id'] ?? 'Unknown',
      geometry = CadastralGeometry.fromJson(json['geometry'] ?? {}),
      properties = CadastralProperties.fromJson(json['properties'] ?? {});
}

class CadastralGeometry {
  String type;
  List<List<List<List<double>>>> coordinates;

  CadastralGeometry.fromJson(Map<String, dynamic> json)
    : type = json['type'] ?? 'Unknown',
      coordinates =
          (json['coordinates'] as List?)
              ?.map(
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
              .toList() ??
          [];
}

class CadastralProperties {
  String surveyNo;
  String villageName;

  CadastralProperties.fromJson(Map<String, dynamic> json)
    : surveyNo = json['survey_no'] ?? 'Unknown',
      villageName = json['village_name'] ?? 'Unknown';
}
