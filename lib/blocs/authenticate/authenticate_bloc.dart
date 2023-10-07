import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki_web/blocs/orders/orders_cubit.dart';
import 'package:ilayki_web/blocs/requests/requests_cubit.dart';
import 'package:ilayki_web/blocs/userchat/userchat_cubit.dart';
import 'package:ilayki_web/blocs/wares/wares_cubit.dart';

import '../../models/user.dart' as modal;

part 'authenticate_event.dart';
part 'authenticate_state.dart';

class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");
  final Reference _pfpsRef = FirebaseStorage.instance.ref("pfps");
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Reference _storage = FirebaseStorage.instance.ref();
  WaresCubit _waresCubit;
  UserchatCubit _userchatCubit;
  OrdersCubit _ordersCubit;
  RequestsCubit _requestsCubit;

  AuthenticateBloc(
    this._waresCubit,
    this._userchatCubit,
    this._ordersCubit,
    this._requestsCubit,
  ) : super(AuthInit()) {
    on<InitEvent>(_init);
    on<LoginEvent>(_login);
    on<LogoutEvent>(_logout);
    on<DeleteEvent>(_delete);
    on<RegisterEvent>(_register);
  }

  void _init(InitEvent event, Emitter<AuthenticateState> emit) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        emit(AuthSuccessful(user: user));
      } else {
        emit(AuthReset());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    }
  }

  /// Signs in the user to firebase emitting AuthSuccess state. Also
  /// emits AuthError state on firebase error during the sign out event and
  /// AuthProcessing state after the login event
  FutureOr<void> _login(
      LoginEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      final UserCredential credentials = await _auth.signInWithEmailAndPassword(
          email: event.email, password: event.password);
      emit(AuthSuccessful(user: credentials.user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    }
  }

  /// Signs out the user from firebase emitting AuthReset state. Also
  /// emits AuthError state on firebase error during the sign out event and
  /// AuthProcessing state after the logout event
  FutureOr<void> _logout(
      LogoutEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      await _auth.signOut();
      emit(AuthReset());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    }
  }

  /// deletes out the user from firebase emitting LogoutEvent. Also
  /// emits AuthError state on firebase error during the delete or
  /// sign out event and AuthProcessing state after the logout event
  FutureOr<void> _delete(
      DeleteEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());

      /// Products Images
      final products = _waresCubit.getProductsForUser(_auth.currentUser!.uid);
      for (var element in products) {
        _storage.child("images").child(element.pid).delete();
      }

      /// Chats
      final chatsRef = _userchatCubit.state.chatRefs
          .where((element) => element.contains(_auth.currentUser!.uid))
          .toList();
      for (var element in chatsRef) {
        _database.child("chats").child(element).remove();
      }

      /// Others Orders
      final orders = _ordersCubit.state.orders;
      for (var order in orders!) {
        _database
            .child("requests")
            .child(order.ownerUid)
            .child(order.requestRef!)
            .remove();
      }
      _database.child("orders").child(_auth.currentUser!.uid).remove();

      /// Others Requests
      final requests = _requestsCubit.state.requests;
      for (var request in requests!) {
        _database
            .child("orders")
            .child(request.buyerUid)
            .child(request.orderRef!)
            .remove();
      }
      _database.child("requests").child(_auth.currentUser!.uid).remove();

      /// Products
      _database.child("products").child(_auth.currentUser!.uid).remove();
      _usersRef.child(_auth.currentUser!.uid).remove();
      _pfpsRef.child(_auth.currentUser!.uid).delete();
      await _auth.currentUser!.delete();
      emit(AuthReset());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    } on FirebaseException catch (e) {
      emit(DatabaseException(exception: e));
    }
  }

  /// Registers the user to the Firebase, updates their profile picture
  ///  and display name and Signs them Out. Also emits AuthError state on
  ///  firebase error during the register or sign out event and AuthProcessing
  /// state after the registerd event
  FutureOr<void> _register(
      RegisterEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
              email: event.email, password: event.password);

      if (credential.user != null) {
        await credential.user!.updateDisplayName(event.displayName);
        final userPfpRef = _pfpsRef.child(credential.user!.uid);
        final pfpUrl =
            await (await userPfpRef.putData(event.pfp)).ref.getDownloadURL();
        await credential.user!.updatePhotoURL(pfpUrl);
        add(LogoutEvent());

        final user = modal.User(
          uid: credential.user!.uid,
          displayName: event.displayName,
          email: event.email,
          pfp: pfpUrl,
        );
        final userRef = _usersRef.child(user.uid);
        await userRef.set(user.toJson());

        emit(AuthRegistered());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    } on FirebaseException catch (e) {
      emit(DatabaseException(exception: e));
    }
  }
}
