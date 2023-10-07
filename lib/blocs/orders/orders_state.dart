part of 'orders_cubit.dart';

abstract class OrdersState {
  final List<Order>? orders;

  const OrdersState({this.orders});
}

class OrdersInit extends OrdersState {
  OrdersInit() : super(orders: List.empty(growable: true));
}

class OrdersPopulate extends OrdersState {
  const OrdersPopulate({required super.orders});
}
