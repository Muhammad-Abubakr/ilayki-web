// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'item.dart';

class OrderItem {
  final Item item;
  final int quantity;

  OrderItem({
    required this.item,
    required this.quantity,
  });

  OrderItem copyWith({
    Item? item,
    int? quantity,
  }) {
    return OrderItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'item': item.toMap(),
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      item: Item.fromMap(map['item'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderItem(item: $item, quantity: $quantity)';

  @override
  bool operator ==(covariant OrderItem other) {
    if (identical(this, other)) return true;

    return other.item == item && other.quantity == quantity;
  }

  @override
  int get hashCode => item.hashCode ^ quantity.hashCode;
}
