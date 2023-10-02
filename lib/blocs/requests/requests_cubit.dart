import 'dart:async';
import 'dart:convert';

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
          if (key.toString().split('+')[1] == myUID) {
            // set this key as the ref to our requests
            final requestsRef = _requests.child(key);

            // print(requestsRef);
            // get all the requests between these two users
            final data =
                (await requestsRef.get()).value as Map<dynamic, dynamic>?;

            if (data != null) {
              // print(data.values);
              // for each request in the requests
              for (var request in data.values) {
                // parse each request to Order
                final parsedRequest = Order.fromJson(request.toString());

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
    final requestRef =
        _requests.child('${order.buyerID}+${order.sellerID}/${order.refID}');
    final orderRef = FirebaseDatabase.instance
        .ref('orders/${order.buyerID}+${order.sellerID}/${order.refID}');
    final notificationsRef =
        FirebaseDatabase.instance.ref('notifications/${order.buyerID}');
    final notificationRef = notificationsRef.push();

    //   Approach change from deleting to updating the status of the order
    //   and placing it in the orders along with the requests so for that we
    //   will need to get the order and then update the status of the order
    final data = await requestRef.get();

    if (data.value != null) {
      final request = jsonDecode(data.value.toString());

      // parse each request to Order
      final parsedRequest = Order.fromJson(json.encode(request));
      final updatedRequest = parsedRequest.copyWith(
          status: OrderStatus.denied, time: DateTime.now());
      await requestRef.set(updatedRequest.toJson());
      await orderRef.set(updatedRequest.toJson());
      await notificationRef.set(updatedRequest.toJson());
    }
  }

  /* Accept Request */
  void accept(Order order) async {
    final requestRef =
        _requests.child('${order.buyerID}+${order.sellerID}/${order.refID}');
    final orderRef = FirebaseDatabase.instance
        .ref('orders/${order.buyerID}+${order.sellerID}/${order.refID}');
    final notificationsRef =
        FirebaseDatabase.instance.ref('notifications/${order.buyerID}');
    final notificationRef = notificationsRef.push();

    //   Approach change from deleting to updating the status of the order
    //   and placing it in the orders along with the requests so for that we
    //   will need to get the order and then update the status of the order
    final data = await requestRef.get();

    if (data.value != null) {
      final request = jsonDecode(data.value.toString());

      // parse each request to Order
      final parsedRequest = Order.fromJson(json.encode(request));
      final updatedRequest = parsedRequest.copyWith(
          status: OrderStatus.accepted, time: DateTime.now());
      await requestRef.set(updatedRequest.toJson());
      await orderRef.set(updatedRequest.toJson());
      await notificationRef.set(updatedRequest.toJson());
    }
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
