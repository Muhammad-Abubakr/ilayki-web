part of 'sales_cubit.dart';

abstract class SalesState {
  final List<Order> sales;

  const SalesState(this.sales);
}

class SalesInitial extends SalesState {
  const SalesInitial(super.sales);
}

class SalesUpdate extends SalesState {
  const SalesUpdate(super.sales);
}
