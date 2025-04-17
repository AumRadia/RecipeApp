class Model {
  String? label;
  String? image;
  String? source;
  String? url;
  int calories;
  List<String> allergies;
  List<String> diets;

  Model({
    required this.image,
    required this.label,
    required this.source,
    required this.url,
    required this.calories,
    required this.allergies,
    required this.diets,
  });

  factory Model.fromMap(Map<String, dynamic> parsedJson) {
    return Model(
      image: parsedJson["image"],
      label: parsedJson["label"],
      source: parsedJson["source"],
      url: parsedJson["url"],
      calories: parsedJson["calories"],
      allergies: parsedJson["allergies"] != null
          ? List<String>.from(parsedJson["allergies"])
          : [],
      diets: parsedJson["diets"] != null
          ? List<String>.from(parsedJson["diets"])
          : [],
    );
  }
}
