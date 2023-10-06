import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../models/user.dart' as model;

part 'userbase_event.dart';
part 'userbase_state.dart';

class UserbaseBloc extends Bloc<UserbaseEvent, UserbaseState> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");

  UserbaseBloc() : super(UserbaseInit()) {
    on<InitEvent>(_init);
  }

  FutureOr<void> _init(InitEvent event, Emitter<UserbaseState> emit) async {
    try {
      final snapshot = await _usersRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<model.User> users = List.empty(growable: true);
        for (var user in data.values) {
          final parsed = model.User.fromJson(user.toString());
          users.add(parsed);
        }
        emit(UserbasePopulate(users: users));
      }
    } on FirebaseException catch (e) {
      log("${e.message}");
    }
  }

  model.User getUser(String uid) {
    return state.users!.firstWhere((element) => element.uid == uid);
  }
}
