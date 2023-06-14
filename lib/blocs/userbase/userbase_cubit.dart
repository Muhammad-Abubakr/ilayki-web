import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/user.dart';

part 'userbase_state.dart';

class UserbaseCubit extends Cubit<UserbaseState> {
  /* getting the users ref from firebase realtime database*/
  final _customersRef = FirebaseDatabase.instance.ref("users/customers");
  final _sellersRef = FirebaseDatabase.instance.ref("users/sellers");

  /* stream ref holder (for cancellation) while disposing*/
  late StreamSubscription _customersStreamHolder;
  late StreamSubscription _sellersStreamHolder;

  UserbaseCubit()
      : super(const UserbaseInitial(
          customer: null,
          seller: null,
        ));

  /* Initialize */
  Future<void> initialize() async {
    /* Subscribing to Customers stream */
    _customersStreamHolder = _customersRef.onValue.listen((event) {
      /* Container for collecting users */
      final List<User> users = List.empty(growable: true);

      /* Abstracting the data from the data event */
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if data not null populate the users
      if (data != null) {
        for (var user in data.values) {
          // parse the user
          final parsedUser = User.fromJson(user.toString());

          users.add(parsedUser);
        }
      }

      /* emit the new state after collection */
      debugPrint('Customers: $users');
      emit(UserbaseUpdate(
        customer: users,
        seller: state.seller ?? [],
      ));
    });

    /* Subscribing to Sellers stream */
    _sellersStreamHolder = _sellersRef.onValue.listen((event) {
      /* Container for collecting users */
      final List<User> users = List.empty(growable: true);

      /* Abstracting the data from the data event */
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if data not null populate the users
      if (data != null) {
        for (var user in data.values) {
          // parse the user
          final parsedUser = User.fromJson(user.toString());

          users.add(parsedUser);
        }
      }
      /* emit the new state after collection */
      debugPrint('Sellers: $users');
      emit(UserbaseUpdate(
        customer: state.customer ?? [],
        seller: users,
      ));
    });
  }

  /* Single User Getter */
  User getUser(String uid) {
    final customerIdx = state.customer!.indexWhere((u) => u.uid == uid);
    debugPrint(state.customer.toString());
    debugPrint(uid);

    if (customerIdx == -1) {
      final sellerIdx = state.seller!.indexWhere((u) => u.uid == uid);
      debugPrint(uid);
      debugPrint(state.seller.toString());

      return state.seller![sellerIdx];
    } else {
      return state.customer![customerIdx];
    }
  }

  /* Dispose */
  Future<void> dispose() async {
    await _customersStreamHolder.cancel();
    await _sellersStreamHolder.cancel();

    // clearing the state
    emit(const UserbaseUpdate(
      customer: null,
      seller: null,
    ));
    if (kDebugMode) {
      print("Userbase stream cancelled...");
    }
  }
}
