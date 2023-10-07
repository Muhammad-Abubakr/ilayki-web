import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../wares/wares_cubit.dart';

part 'basket_state.dart';

class BasketCubit extends Cubit<BasketState> {
  late StreamSubscription _userStream;
  User? _currentUser;
  late final WaresCubit _waresCubit;

  BasketCubit(this._waresCubit) : super(BasketInit());

  void initialize() {
    _userStream = FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
    });
  }

  void dispose() {
    _userStream.cancel();
    emit(const BasketReset());
  }

  double getTotal(List<Order> products) {
    double total = 0;
    for (var order in products) {
      final product = _waresCubit.getProduct(order.pid);
      total += product.price * order.quantity;
    }
    return total;
  }

  void addToBasket(Product product) {
    List<Order> updatedOrders = List.empty(growable: true);
    Order order = Order(
      pid: product.pid,
      ownerUid: product.ownerUid,
      buyerUid: _currentUser!.uid,
      timestamp: DateTime.now(),
      quantity: 1,
    );

    if (state.purchase == null || state.purchase!.isEmpty) {
      List<Order> orders = [order];
      emit(BasketUpdate(purchase: orders, totalValue: getTotal(orders)));
    } else {
      int idx =
          state.purchase!.indexWhere((element) => element.pid == product.pid);
      if (idx > -1) {
        Order order = state.purchase![idx];
        Order updatedOrder = order.copyWith(quantity: order.quantity + 1);
        state.purchase!.replaceRange(idx, idx + 1, [updatedOrder]);
        updatedOrders = [...state.purchase!];
      } else {
        /// true positive for above condition
        updatedOrders = [...state.purchase!, order];
      }

      double updatedTotal = getTotal(updatedOrders);
      emit(BasketUpdate(purchase: updatedOrders, totalValue: updatedTotal));
    }
  }

  void removeFromBasket(String pid) {
    state.purchase!.removeWhere((o) => o.pid == pid);

    if (state.purchase!.isEmpty) {
      emit(const BasketReset());
    } else {
      List<Order> updatedPurchase = [...state.purchase!];
      double updatedTotal = getTotal(updatedPurchase);

      emit(BasketUpdate(purchase: updatedPurchase, totalValue: updatedTotal));
    }
  }

  void decreaseQuantity(String pid) {
    int orderIdx = state.purchase!.indexWhere((element) => element.pid == pid);
    Order order = state.purchase![orderIdx];

    if (order.quantity == 1) {
      removeFromBasket(pid);
    } else {
      Order updatedOrder = order.copyWith(quantity: order.quantity - 1);
      state.purchase!.replaceRange(orderIdx, orderIdx + 1, [updatedOrder]);

      List<Order> updatedPurchase = [...state.purchase!];
      double updatedTotal = getTotal(updatedPurchase);

      emit(BasketUpdate(purchase: updatedPurchase, totalValue: updatedTotal));
    }
  }

  void placeOrder() async {
    try {
      emit(BasketProcessing(
        totalValue: state.totalValue,
        purchase: state.purchase,
        exception: state.exception,
      ));
      if (state.purchase != null && state.purchase!.isNotEmpty) {
        for (var order in state.purchase!) {
          final requestsRef = FirebaseDatabase.instance.ref("requests");
          final ordersRef = FirebaseDatabase.instance.ref("orders");
          final ownersRef = requestsRef.child(order.ownerUid);
          final customerRef = ordersRef.child(_currentUser!.uid);

          final newPurchaseRef = customerRef.push();
          final newOrderRef = ownersRef.push();

          Order purchase = order.copyWith(
            orderRef: newPurchaseRef.key,
            requestRef: newOrderRef.key,
          );

          await newOrderRef.set(purchase.toJson());
          await newPurchaseRef.set(purchase.toJson());

          emit(const BasketOrderPlaced());
        }
      }
    } on FirebaseException catch (e) {
      emit(BasketError(exception: e));
    }
  }
}
