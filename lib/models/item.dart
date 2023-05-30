import 'package:equatable/equatable.dart';

class Item extends Equatable {
  // Attributes
  final String name;
  final double price;
  final String description;
  final String image;

  // Constructor
  const Item({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  @override
  List<Object> get props => [name, price, description, image];
}
