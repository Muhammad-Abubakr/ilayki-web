import 'dart:convert';

class Order {
  final String pid;
  final String ownerUid;
  final String buyerUid;
  final int quantity;
  final DateTime timestamp;

  Order({
    required this.pid,
    required this.ownerUid,
    required this.buyerUid,
    required this.quantity,
    required this.timestamp,
  });

  Order copyWith({
    String? pid,
    String? ownerUid,
    String? buyerUid,
    int? quantity,
    DateTime? timestamp,
  }) {
    return Order(
      pid: pid ?? this.pid,
      ownerUid: ownerUid ?? this.ownerUid,
      buyerUid: buyerUid ?? this.buyerUid,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pid': pid,
      'ownerUid': ownerUid,
      'buyerUid': buyerUid,
      'quantity': quantity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      pid: map['pid'] as String,
      ownerUid: map['ownerUid'] as String,
      buyerUid: map['buyerUid'] as String,
      quantity: map['quantity'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(pid: $pid, ownerUid: $ownerUid, buyerUid: $buyerUid, quantity: $quantity, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.pid == pid &&
        other.ownerUid == ownerUid &&
        other.buyerUid == buyerUid &&
        other.quantity == quantity &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return pid.hashCode ^
        ownerUid.hashCode ^
        buyerUid.hashCode ^
        quantity.hashCode ^
        timestamp.hashCode;
  }
}
