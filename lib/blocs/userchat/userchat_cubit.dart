import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
part 'userchat_state.dart';

class UserchatCubit extends Cubit<UserchatState> {
  final _chatsRef = FirebaseDatabase.instance.ref("chats");
  late StreamSubscription _chatsStream;

  UserchatCubit() : super(UserchatInit());

  /* Initialize the cubit */
  void intialize() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _chatsStream = _chatsRef.onValue.listen((event) {
          final List<String> chatRefs = List.empty(growable: true);
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            for (var ref in data.keys) {
              if (ref.toString().contains(user.uid)) {
                chatRefs.add(ref);
              }
            }
          }
          emit(UserchatPopulate(chatRefs));
        });
      }
    });
  }

  /* disposing streams */
  void dispose() {
    _chatsStream.cancel();
    emit(UserchatReset());
  }
}
