// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Item extends Equatable {
  // Attributes
  final String id;
  final String name;
  final double price;
  final String owner;
  final String description;
  final String image;

  // Constructor
  const Item({
    required this.id,
    required this.owner,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  @override
  List<Object> get props => [id, name, price, description, image, owner];

  @override
  bool get stringify => true;

  /* Json Serialization */
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'owner': owner,
      'description': description,
      'image': image,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      owner: map['owner'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);
}
