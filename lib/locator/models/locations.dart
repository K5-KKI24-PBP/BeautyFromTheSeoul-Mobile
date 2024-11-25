// To parse this JSON data, do
//
//     final locations = locationsFromJson(jsonString);

import 'dart:convert';

List<Locations> locationsFromJson(String str) => List<Locations>.from(json.decode(str).map((x) => Locations.fromJson(x)));

String locationsToJson(List<Locations> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Locations {
    Model model;
    String pk;
    Fields fields;

    Locations({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Locations.fromJson(Map<String, dynamic> json) => Locations(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String storeName;
    String streetName;
    String district;
    String gmapsLink;
    String storeImage;

    Fields({
        required this.storeName,
        required this.streetName,
        required this.district,
        required this.gmapsLink,
        required this.storeImage,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        storeName: json["store_name"],
        streetName: json["street_name"],
        district: json["district"],
        gmapsLink: json["gmaps_link"],
        storeImage: json["store_image"],
    );

    Map<String, dynamic> toJson() => {
        "store_name": storeName,
        "street_name": streetName,
        "district": district,
        "gmaps_link": gmapsLink,
        "store_image": storeImage,
    };
}

enum Model {
    LOCATOR_LOCATIONS
}

final modelValues = EnumValues({
    "locator.locations": Model.LOCATOR_LOCATIONS
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
