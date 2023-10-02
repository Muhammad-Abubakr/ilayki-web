// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Item {
  // Attributes
  final String id;
  final String name;
  final double price;
  final String owner;
  final String description;
  final double? rating;
  final int ratingCount;
  final String image;

  // Constructor
  const Item({
    required this.id,
    required this.owner,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.ratingCount,
    this.rating,
  });

  /* Json Serialization */
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'owner': owner,
      'description': description,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
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
      rating: map['rating'] as double?,
      ratingCount: map['ratingCount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          owner == other.owner &&
          description == other.description &&
          rating == other.rating &&
          ratingCount == other.ratingCount &&
          image == other.image;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      owner.hashCode ^
      description.hashCode ^
      rating.hashCode ^
      ratingCount.hashCode ^
      image.hashCode;

  Item copyWith({
    String? id,
    String? name,
    double? price,
    String? owner,
    String? description,
    double? rating,
    int? ratingCount,
    String? image,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      image: image ?? this.image,
    );
  }
}
