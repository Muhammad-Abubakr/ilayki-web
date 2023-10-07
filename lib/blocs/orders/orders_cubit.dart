import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/order.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final DatabaseReference _orders = FirebaseDatabase.instance.ref('orders');
  late StreamSubscription _ordersStream;

  OrdersCubit() : super(OrdersInit());

  void initialize() {
    _ordersStream = _orders.onValue.listen((event) async {
      final myUID = FirebaseAuth.instance.currentUser?.uid;
      final List<Order> allOrders = List.empty(growable: true);
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        for (var key in data.keys) {
          if (key == myUID) {
            final ordersRef = _orders.child(key);
            final data =
                (await ordersRef.get()).value as Map<dynamic, dynamic>?;

            if (data != null) {
              for (var order in data.values) {
                final parsedOrder = Order.fromJson(order.toString());
                allOrders.add(parsedOrder);
              }
            }
          }
        }
      }
      emit(OrdersPopulate(orders: allOrders));
    });
  }

  void dispose() async {
    await _ordersStream.cancel();
    emit(OrdersPopulate(orders: List.empty(growable: true)));
  }
}
