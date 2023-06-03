part of 'basket_cubit.dart';

abstract class BasketState extends Equatable {
  final List<OrderItem> orderItems;
  final double totalPrice;

  const BasketState({required this.orderItems, required this.totalPrice});

  @override
  List<Object> get props => [orderItems, totalPrice];
}

class BasketInitial extends BasketState {
  const BasketInitial({required super.orderItems, required super.totalPrice});
}

class BasketUpdate extends BasketState {
  const BasketUpdate({required super.orderItems, required super.totalPrice});
}
