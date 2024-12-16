// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
    String model;
    int pk;
    ReviewFields fields;

    Review({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        model: json["model"],
        pk: json["pk"],
        fields: ReviewFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class ReviewFields {
    String product;
    int user;
    String username;
    int rating;
    String comment;
    DateTime createdAt;

    ReviewFields({
        required this.product,
        required this.user,
        required this.username,
        required this.rating,
        required this.comment,
        required this.createdAt,
    });

    factory ReviewFields.fromJson(Map<String, dynamic> json) {
        final username = json["username"];
        
        return ReviewFields(
            product: json["product"],
            user: json["user"],
            username: username ?? "Unknown User",  // Use null-safe operator
            rating: json["rating"],
            comment: json["comment"],
            createdAt: DateTime.parse(json["created_at"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "product": product,
        "user": user,
        "username": username,
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
    };
}
