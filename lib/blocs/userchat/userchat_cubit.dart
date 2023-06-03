import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

part 'userchat_state.dart';

class UserchatCubit extends Cubit<UserchatState> {
  /* Firebase Database instance */
  final _chatsRef = FirebaseDatabase.instance.ref("chats");

  /* Stream of Chat Ref */
  late final StreamSubscription _chatsStream;

  /* Stream of Firebase */
  late final StreamSubscription _firebaseStream;

  UserchatCubit() : super(const UserchatInitial([]));

  /* Initialize the cubit */
  void intialize() async {
    _firebaseStream = FirebaseAuth.instance.authStateChanges().listen((user) {
      // if the user is signed in
      if (user != null) {
        // get all the references for chats
        _chatsStream = _chatsRef.onValue.listen((event) {
          /* chat refs container */
          final List<String> chatRefs = List.empty(growable: true);

          // get the data
          final data = event.snapshot.value as Map<dynamic, dynamic>?;

          // if there is any chat data
          if (data != null) {
            // for every chat key ref in data, filter the ones that contain our user
            for (var ref in data.keys) {
              if (ref.toString().contains(user.uid)) {
                chatRefs.add(ref);
              }
            }

            print(chatRefs);
            /* after all the keys have been collected, emit */
            emit(UserchatUpdate(chatRefs));
          }
        });
      }
    });
  }

  /* disposing streams */
  void dispose() {
    // cancelling streams
    _chatsStream.cancel();
    _firebaseStream.cancel();

    // clearing the state
    emit(const UserchatUpdate([]));

    if (kDebugMode) {
      print("Cancelling user chats stream...");
    }
  }
}
