import 'dart:convert';

class Order {
  final String pid;
  final String ownerUid;
  final String buyerUid;
  final int quantity;
  final DateTime timestamp;
  final String? orderRef;
  final String? requestRef;

  const Order({
    required this.pid,
    required this.ownerUid,
    required this.buyerUid,
    required this.quantity,
    required this.timestamp,
    this.orderRef,
    this.requestRef,
  });

  Order copyWith({
    String? pid,
    String? ownerUid,
    String? buyerUid,
    int? quantity,
    DateTime? timestamp,
    String? orderRef,
    String? requestRef,
  }) {
    return Order(
      pid: pid ?? this.pid,
      ownerUid: ownerUid ?? this.ownerUid,
      buyerUid: buyerUid ?? this.buyerUid,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      orderRef: orderRef ?? this.orderRef,
      requestRef: requestRef ?? this.requestRef,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pid': pid,
      'ownerUid': ownerUid,
      'buyerUid': buyerUid,
      'quantity': quantity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'orderRef': orderRef,
      'requestRef': requestRef,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      pid: map['pid'] as String,
      ownerUid: map['ownerUid'] as String,
      buyerUid: map['buyerUid'] as String,
      quantity: map['quantity'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      orderRef: map['orderRef'] != null ? map['orderRef'] as String : null,
      requestRef: map['requestRef'] != null ? map['requestRef'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(pid: $pid, ownerUid: $ownerUid, buyerUid: $buyerUid, quantity: $quantity, timestamp: $timestamp, orderRef: $orderRef, requestRef: $requestRef)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.pid == pid &&
        other.ownerUid == ownerUid &&
        other.buyerUid == buyerUid &&
        other.quantity == quantity &&
        other.timestamp == timestamp &&
        other.orderRef == orderRef &&
        other.requestRef == requestRef;
  }

  @override
  int get hashCode {
    return pid.hashCode ^
        ownerUid.hashCode ^
        buyerUid.hashCode ^
        quantity.hashCode ^
        timestamp.hashCode ^
        orderRef.hashCode ^
        requestRef.hashCode;
  }
}
