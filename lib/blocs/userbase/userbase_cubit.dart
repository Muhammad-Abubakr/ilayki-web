import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/user.dart';

part 'userbase_state.dart';

class UserbaseCubit extends Cubit<UserbaseState> {
  /* getting the users ref from firebase realtime database*/
  final _usersRef = FirebaseDatabase.instance.ref("users");

  /* stream ref holder (for cancellation) while disposing*/
  late final StreamSubscription _streamHolder;

  UserbaseCubit() : super(const UserbaseInitial([]));

  /* Initialize */
  Future<void> initialize() async {
    /* Subscribing to userbase stream */
    _streamHolder = _usersRef.onValue.listen((event) {
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

        /* emit the new state after collection */
        emit(UserbaseUpdate(users));
      }
    });
  }

  /* Dispose */
  Future<void> dispose() async {
    await _streamHolder.cancel();

    // clearing the state
    emit(const UserbaseUpdate([]));
    if (kDebugMode) {
      print("Userbase stream cancelled...");
    }
  }
}
