part of 'basket_cubit.dart';

enum BasketStatus { processing, error, orderPlaced }

abstract class BasketState {
  final List<Order>? purchase;
  final double? totalValue;
  final FirebaseException? exception;

  const BasketState({this.purchase, this.totalValue, this.exception});
}

class BasketUpdate extends BasketState {
  const BasketUpdate({required super.purchase, required super.totalValue});
}

class BasketError extends BasketState {
  const BasketError({required super.exception});
}

class BasketOrderPlaced extends BasketState {
  const BasketOrderPlaced()
      : super(purchase: null, totalValue: null, exception: null);
}

class BasketReset extends BasketState {
  const BasketReset()
      : super(purchase: null, totalValue: null, exception: null);
}

class BasketInit extends BasketState {
  BasketInit()
      : super(
            purchase: List.empty(growable: true),
            totalValue: 0,
            exception: null);
}

class BasketProcessing extends BasketState {
  BasketProcessing({super.purchase, super.totalValue, super.exception});
}
