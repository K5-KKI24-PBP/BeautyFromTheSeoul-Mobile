// To parse this JSON data, do
//
//     final rsvp = rsvpFromJson(jsonString);

import 'dart:convert';

List<Rsvp> rsvpFromJson(String str) => List<Rsvp>.from(json.decode(str).map((x) => Rsvp.fromJson(x)));

String rsvpToJson(List<Rsvp> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Rsvp {
    String model;
    int pk;
    Fields fields;

    Rsvp({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Rsvp.fromJson(Map<String, dynamic> json) => Rsvp(
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
    String event;
    int user;
    bool rsvpStatus;

    Fields({
        required this.event,
        required this.user,
        required this.rsvpStatus,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        event: json["event"],
        user: json["user"],
        rsvpStatus: json["rsvp_status"],
    );

    Map<String, dynamic> toJson() => {
        "event": event,
        "user": user,
        "rsvp_status": rsvpStatus,
    };
}
