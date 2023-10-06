import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/user.dart' as modal;

part 'authenticate_event.dart';
part 'authenticate_state.dart';

class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref("users");
  final Reference _pfpsRef = FirebaseStorage.instance.ref("pfps");

  AuthenticateBloc() : super(AuthInit()) {
    on<InitEvent>(_init);
    on<LoginEvent>(_login);
    on<LogoutEvent>(_logout);
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
  FutureOr<void> _login(LoginEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      final UserCredential credentials =
          await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);
      emit(AuthSuccessful(user: credentials.user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    }
  }

  /// Signs out the user from firebase emitting AuthReset state. Also
  /// emits AuthError state on firebase error during the sign out event and
  /// AuthProcessing state after the logout event
  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      await _auth.signOut();
      emit(AuthReset());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(error: e));
    }
  }

  /// Registers the user to the Firebase, updates their profile picture
  ///  and display name and Signs them Out. Also emits AuthError state on
  ///  firebase error during the register or sign out event and AuthProcessing
  /// state after the registerd event
  FutureOr<void> _register(RegisterEvent event, Emitter<AuthenticateState> emit) async {
    try {
      emit(AuthProcessing());
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: event.email, password: event.password);

      if (credential.user != null) {
        await credential.user!.updateDisplayName(event.displayName);
        final userPfpRef = _pfpsRef.child(credential.user!.uid);
        final pfpUrl = await (await userPfpRef.putData(event.pfp)).ref.getDownloadURL();
        await credential.user!.updatePhotoURL(pfpUrl);
        add(LogoutEvent());

        final user = modal.User(
          uid: credential.user!.uid,
          displayName: event.displayName,
          email: event.email,
          pfp: pfpUrl,
        );
        final userRef = _database.child(user.uid);
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
