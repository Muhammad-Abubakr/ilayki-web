// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'orderitem.dart';

enum OrderType { pickup, delivery }

enum OrderStatus { pending, accepted, denied, completed }

class Order {
  final String refID;
  final String buyerID;
  final String sellerID;
  final List<OrderItem> orderItems;
  final TimeOfDay pickupTime;
  final DateTime pickupDate;
  final OrderStatus status;
  final DateTime time;
  final double totalPrice;
  final OrderType orderType;

  String get productId => refID.substring(refID.length - 4);
  String get ownerId => sellerID.substring(sellerID.length - 4);
  String get parsedDate => time.toString().split(" ")[0];
  String get parsedTime => time.toString().split(" ")[1].split(".")[0];

  Order({
    required this.refID,
    required this.buyerID,
    required this.sellerID,
    required this.pickupTime,
    required this.pickupDate,
    required this.status,
    required this.orderItems,
    required this.time,
    required this.totalPrice,
    required this.orderType,
  });

  Order copyWith({
    String? refID,
    String? buyerID,
    String? sellerID,
    List<OrderItem>? orderItems,
    DateTime? time,
    OrderStatus? status,
    DateTime? pickupDate,
    double? totalPrice,
    OrderType? orderType,
    TimeOfDay? pickupTime,
  }) {
    return Order(
      orderType: orderType ?? this.orderType,
      refID: refID ?? this.refID,
      buyerID: buyerID ?? this.buyerID,
      pickupTime: pickupTime ?? this.pickupTime,
      pickupDate: pickupDate ?? this.pickupDate,
      status: status ?? this.status,
      sellerID: sellerID ?? this.sellerID,
      orderItems: orderItems ?? this.orderItems,
      time: time ?? this.time,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'refID': refID,
      'buyerID': buyerID,
      'sellerID': sellerID,
      'status': describeEnum(status),
      'pickupTime': "${pickupTime.hour}:${pickupTime.minute}",
      'pickupDate': pickupDate.millisecondsSinceEpoch,
      'orderType': describeEnum(orderType),
      'orderItems': orderItems.map((x) => x.toMap()).toList(),
      'time': time.millisecondsSinceEpoch,
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      refID: map['refID'] as String,
      buyerID: map['buyerID'] as String,
      sellerID: map['sellerID'] as String,
      pickupTime: TimeOfDay(
          hour: int.parse(map['pickupTime'].split(':')[0]),
          minute: int.parse(map['pickupTime'].split(':')[1])),
      orderType: OrderType.values
          .firstWhere((element) => describeEnum(element) == map['orderType']),
      status: OrderStatus.values
          .firstWhere((element) => describeEnum(element) == map['status']),
      orderItems: List<OrderItem>.from(
        (map['orderItems'] as List<dynamic>).map<OrderItem>(
          (x) => OrderItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      pickupDate: DateTime.fromMillisecondsSinceEpoch(map['pickupDate'] as int),
      totalPrice: map['totalPrice'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(refID: $refID, status: $status, buyerID: $buyerID, pickupDate: $pickupDate, pickupTime: $pickupTime, sellerID: $sellerID, orderType: $orderType, orderItems: $orderItems, time: $time, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.refID == refID &&
        other.buyerID == buyerID &&
        other.status == status &&
        other.sellerID == sellerID &&
        other.orderType == orderType &&
        other.pickupTime == pickupTime &&
        listEquals(other.orderItems, orderItems) &&
        other.time == time &&
        other.pickupDate == pickupDate &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return refID.hashCode ^
        buyerID.hashCode ^
        status.hashCode ^
        orderType.hashCode ^
        pickupTime.hashCode ^
        pickupDate.hashCode ^
        sellerID.hashCode ^
        orderItems.hashCode ^
        time.hashCode ^
        totalPrice.hashCode;
  }
}
