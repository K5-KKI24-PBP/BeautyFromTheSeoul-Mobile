// To parse this JSON data, do
//
//     final adEntry = adEntryFromJson(jsonString);

import 'dart:convert';

List<AdEntry> adEntryFromJson(String str) => List<AdEntry>.from(json.decode(str).map((x) => AdEntry.fromJson(x)));

String adEntryToJson(List<AdEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdEntry {
    String model;
    String pk;
    Fields fields;

    AdEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory AdEntry.fromJson(Map<String, dynamic> json) => AdEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String brandName;
    String image;
    bool isApproved;

    Fields({
        required this.brandName,
        required this.image,
        required this.isApproved,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        brandName: json["brand_name"],
        image: json["image"],
        isApproved: json["is_approved"],
    );

    Map<String, dynamic> toJson() => {
        "brand_name": brandName,
        "image": image,
        "is_approved": isApproved,
    };
}
