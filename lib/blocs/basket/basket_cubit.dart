import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../models/order.dart';
import '../../models/orderitem.dart';
import '../../models/user.dart' as my_user;

part 'basket_state.dart';

class BasketCubit extends Cubit<BasketState> {
  /* get the database reference */
  final _requests = FirebaseDatabase.instance.ref("requests");

  BasketCubit() : super(const BasketInitial(orderItems: [], totalPrice: 0));

  /* add item */
  void addItem(Item item) {
    // Two things can happen here:
    // checking if the item is present
    final int isPresent =
        state.orderItems.indexWhere((order) => order.item.id == item.id);

    // 1- item is not present => add item with quantity one
    if (isPresent == -1) {
      // wrap the item into orderitem wrapper
      final OrderItem wrappedItem = OrderItem(item: item, quantity: 1);

      // create a new orderItem list
      final List<OrderItem> items = [...state.orderItems, wrappedItem];

      // update the total price
      final double updatedPrice = state.totalPrice + item.price;

      // emit the updated items and price
      emit(BasketUpdate(orderItems: items, totalPrice: updatedPrice));
    }

    // 2 - item is present => increase quantity
    else {
      // we have the index for the item, we only need to update it's quantity and total price
      final presentState = state.orderItems[isPresent];

      // update the quantity
      final updatedState =
          presentState.copyWith(quantity: presentState.quantity + 1);

      // replace the previous item
      state.orderItems.replaceRange(isPresent, isPresent + 1, [updatedState]);
      final updatedItems = [...state.orderItems];

      // increase the total price
      final updatedPrice = state.totalPrice + item.price;

      // emit the state
      emit(BasketUpdate(orderItems: updatedItems, totalPrice: updatedPrice));
    }
  }

  /* remove item */
  void removeItem(Item item) {
    // Two things can happen here:
    final int prevStateIndex =
        state.orderItems.indexWhere((order) => order.item.id == item.id);
    final OrderItem prevState = state.orderItems[prevStateIndex];

    // 1 - item is at quantity 1 => remove item from basket
    if (prevState.quantity == 1) {
      // remove the item
      state.orderItems.removeAt(prevStateIndex);

      // get the updated list
      final updatedItems = [...state.orderItems];

      // decrement the total price
      final updatedPrice = state.totalPrice - item.price;

      // emit the new state
      emit(BasketUpdate(orderItems: updatedItems, totalPrice: updatedPrice));
    }

    // 2- item is at quantity > 1 => decrease quantity of the item
    else {
      // we have the index for the item, we only need to update it's quantity and total price
      final presentState = state.orderItems[prevStateIndex];

      // update the quantity
      final updatedState =
          presentState.copyWith(quantity: presentState.quantity - 1);

      // replace the previous item
      state.orderItems
          .replaceRange(prevStateIndex, prevStateIndex + 1, [updatedState]);
      final updatedItems = [...state.orderItems];

      // decrease the total price
      final updatedPrice = state.totalPrice - item.price;

      // emit the state
      emit(BasketUpdate(orderItems: updatedItems, totalPrice: updatedPrice));
    }
  }

  /* place order */
  void placeOrder(my_user.User seller, TimeOfDay pickupTime,
      OrderType orderType, DateTime pickupDate) async {
    // create a ref at the requests in format BuyerID+SellerID
    final String buyerUID = FirebaseAuth.instance.currentUser!.uid;

    final DatabaseReference ref = _requests.child('$buyerUID+${seller.uid}');

    // create a new ref at the orders/request between two users so they don't get overwritten
    final requestRef = ref.push();
    final DatabaseReference notificationsRef =
        FirebaseDatabase.instance.ref('notifications/$buyerUID');
    final DatabaseReference buyerNotification = notificationsRef.push();

    // create the Order model
    final Order order = Order(
      refID: requestRef.path.split('/').last,
      buyerID: buyerUID,
      sellerID: seller.uid,
      status: OrderStatus.pending,
      orderType: orderType,
      pickupTime: pickupTime,
      pickupDate: pickupDate,
      orderItems: state.orderItems,
      totalPrice: state.totalPrice,
      time: DateTime.now(),
    );

    // convert to JSON
    final encodedOrder = order.toJson();

    // set the order at the reference
    await requestRef.set(encodedOrder);
    await buyerNotification.set(encodedOrder);

    // emit the basket to be clear
    emit(const BasketUpdate(orderItems: [], totalPrice: 0));
  }

  // clear basket
  void clear() {
    // clear the basket items
    emit(const BasketUpdate(orderItems: [], totalPrice: 0));

    if (kDebugMode) {
      print("Clearing the basket...");
    }
  }
}
