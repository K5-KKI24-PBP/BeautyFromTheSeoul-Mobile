// To parse this JSON data, do
//
//     final events = eventsFromJson(jsonString);

import 'dart:convert';

List<Events> eventsFromJson(String str) => List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

String eventsToJson(List<Events> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
    String model;
    String pk;
    Fields fields;

    Events({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Events.fromJson(Map<String, dynamic> json) => Events(
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
    String? name;  // Can be null
    String? description;  // Can be null
    DateTime startDate;  // Assuming date fields are always present
    DateTime endDate;  // Assuming date fields are always present
    String? location;  // Can be null
    String? promotionType;  // Can be null

    Fields({
        required this.name,
        required this.description,
        required this.startDate,
        required this.endDate,
        required this.location,
        required this.promotionType,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
      name: json['name'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      promotionType: json['promotion_type'] as String?,
      location: json['location'] as String?,
    );


    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "location": location,
        "promotion_type": promotionType,
    };
}

