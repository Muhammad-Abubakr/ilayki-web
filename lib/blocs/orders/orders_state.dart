part of 'orders_cubit.dart';

abstract class OrdersState {
  final List<Order> orders;

  const OrdersState(this.orders);
}

class OrdersInitial extends OrdersState {
  const OrdersInitial(super.orders);
}

class OrdersUpdate extends OrdersState {
  const OrdersUpdate(super.orders);
}
