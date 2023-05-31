import 'package:equatable/equatable.dart';

class Item extends Equatable {
  // Attributes
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;

  // Constructor
  const Item({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  @override
  List<Object> get props => [id, name, price, description, image];
}
