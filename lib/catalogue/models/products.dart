// To parse this JSON data, do
//
//     final products = productsFromJson(jsonString);

import 'dart:convert';

List<Products> productsFromJson(String str) => List<Products>.from(json.decode(str).map((x) => Products.fromJson(x)));

String productsToJson(List<Products> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Products {
    Model model;
    String pk;
    Fields fields;

    Products({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Products.fromJson(Map<String, dynamic> json) => Products(
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
    String productName;
    String productBrand;
    String productType;
    String productDescription;
    String price;
    String image;

    Fields({
        required this.productName,
        required this.productBrand,
        required this.productType,
        required this.productDescription,
        required this.price,
        required this.image,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        productName: json["product_name"],
        productBrand: json["product_brand"],
        productType: json["product_type"],
        productDescription: json["product_description"],
        price: json["price"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "product_name": productName,
        "product_brand": productBrand,
        "product_type": productType,
        "product_description": productDescription,
        "price": price,
        "image": image,
    };
}

enum Model {
    CATALOGUE_PRODUCTS
}

final modelValues = EnumValues({
    "catalogue.products": Model.CATALOGUE_PRODUCTS
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
