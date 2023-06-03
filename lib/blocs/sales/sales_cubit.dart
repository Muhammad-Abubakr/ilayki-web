import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/models/order.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  /* acquiring the database reference */
  final DatabaseReference _sales = FirebaseDatabase.instance.ref('orders');

  /* Streams Subscription */
  late StreamSubscription _stream;

  SalesCubit() : super(const SalesInitial([]));

  /* initialize */
  void initialize() {
    // get the sales that are only for the current user
    _stream = _sales.onValue.listen((event) async {
      // get the current user
      final myUID = FirebaseAuth.instance.currentUser?.uid;

      /* container for sales */
      final List<Order> allSales = List.empty(growable: true);

      // extract the data
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if the data exists
      if (data != null) {
        // filter the keys
        for (var key in data.keys) {
          // checking if the owner id is this user
          // print(key.toString().split('+')[1]);
          // print(myUID);
          if (key.toString().split('+')[1] == myUID) {
            // set this key as the ref to our sales
            final salesRef = _sales.child(key);

            // print(salesRef);
            // get all the sales between these two users
            final data = (await salesRef.get()).value as Map<dynamic, dynamic>?;

            if (data != null) {
              // print(data.values);
              // for each sale in the sales
              for (var sale in data.values) {
                // parse each sale to Order
                final parsedSale = Order.fromJson(sale.toString());

                // print(parsedSale);
                // add to container
                allSales.add(parsedSale);
              }
            }
          }
        }
      }

      emit(SalesUpdate(allSales));
    });
  }

  /* disposing the stream */
  void dispose() async {
    await _stream.cancel();

    // clearing the state
    emit(const SalesUpdate([]));

    if (kDebugMode) {
      print("Cancelling sale stream...");
    }
  }
}
