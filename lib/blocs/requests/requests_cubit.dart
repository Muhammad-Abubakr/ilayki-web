import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/models/order.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  /* acquiring the database reference */
  final DatabaseReference _requests = FirebaseDatabase.instance.ref('requests');

  /* Streams Subscription */
  late StreamSubscription _stream;

  RequestsCubit() : super(const RequestsInitial([]));

  /* initialize */
  void initialize() {
    // get the requests that are only for the current user
    _stream = _requests.onValue.listen((event) async {
      // get the current user
      final myUID = FirebaseAuth.instance.currentUser?.uid;

      /* container for requests */
      final List<Order> allRequests = List.empty(growable: true);

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
            // set this key as the ref to our requests
            final requestsRef = _requests.child(key);

            // print(requestsRef);
            // get all the requests between these two users
            final data = (await requestsRef.get()).value as Map<dynamic, dynamic>?;

            if (data != null) {
              // print(data.values);
              // for each request in the requests
              for (var request in data.values) {
                // parse each request to Order
                final parsedRequest = Order.fromJson(request.toString());

                // print(parsedRequest);
                // add to container
                allRequests.add(parsedRequest);
              }
            }
          }
        }
      }

      emit(RequestsUpdate(allRequests));
    });
  }

  /* Decline Request */
  void decline(Order order) async {
    // goal: remove the request from the requests collection in database
    // 1- get the reference to the order
    final orderRef = _requests.child('${order.buyerID}+${order.sellerID}/${order.refID}');

    // 2 - delete the item
    await orderRef.remove();
  }

  /* Accept Request */
  void accept(Order order) async {
    // goal: remove the request from the requests collection in database
    // and add it to confirmed orders
    decline(order); // will remove it from requests

    // now adding to confirmed orders
    // first getting the ref to it
    final orderRef = FirebaseDatabase.instance
        .ref('orders/${order.buyerID}+${order.sellerID}/${order.refID}');

    // set the order to new reference
    await orderRef.set(order.toJson());
  }

  /* disposing the stream */
  void dispose() async {
    await _stream.cancel();

    // clearing the state
    emit(const RequestsUpdate([]));

    if (kDebugMode) {
      print("Cancelling request stream...");
    }
  }
}
