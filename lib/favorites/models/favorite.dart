// To parse this JSON data, do
//
//     final favorite = favoriteFromJson(jsonString);

import 'dart:convert';

List<Favorite> favoriteFromJson(String str) => List<Favorite>.from(json.decode(str).map((x) => Favorite.fromJson(x)));

String favoriteToJson(List<Favorite> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Favorite {
    String model;
    int pk;
    Fields fields;

    Favorite({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
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
    int user;
    String skincareProduct;
    DateTime createdAt;

    Fields({
        required this.user,
        required this.skincareProduct,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        skincareProduct: json["skincare_product"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "skincare_product": skincareProduct,
        "created_at": createdAt.toIso8601String(),
    };
}
