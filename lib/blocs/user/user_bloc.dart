import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ilayki/services/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  /* ================================ Fields ================================ */
  /* linking to our service cursor `AuthService` we created under /lib/srevices/auth.dart
  this will be used to call all the intermediary service calls to FirebaseAuth */
  late final AuthService _auth;

  /* ================================ UserBloc constructor ================================ 

     Extends the Bloc with event type UserEvent and state type UserState
     {may need to look into dart streams for a better understanding of how it works}
     [https://www.youtube.com/watch?v=w6XWjpBK4W8&list=PLptHs0ZDJKt_T-oNj_6Q98v-tBnVf-S_o]

     Above is the link to a great playlist for flutter_bloc by flutterly
   */
  UserBloc() : super(const UserInitial(state: UserStates.signedOut)) {
    _auth = AuthService();

    // =============== Subscribing to Firebase User Stream ================ //
    _auth.subscribe.listen((element) => add(_UserUpdateEvent(element)));

    // =============== Hooking Handlers ================ //
    // PRIVATE
    on<_UserUpdateEvent>(_subscriptionHandler);

    // CLIENT
    on<UserSignInAnonymously>(_signInUserAnonHandler);
    on<RegisterUserWithEmailAndPassword>(_registerUserWithEmailAndPassHandler);
    on<UserSignInWithEmailAndPassword>(_signInUserWithEmailAndPassHandler);
    on<UserSignOut>(_signOutUserHandler);
  }

  /* 
    Subscription Handler
   */
  FutureOr<void> _subscriptionHandler(_UserUpdateEvent event, Emitter<UserState> emit) {
    // updates the Bloc about the change in user state from the firebase subscription
    if (kDebugMode) {
      print(state.user);
    }

    // If the user has signed out
    if (event.user == null) {
      emit(UserUpdate(
        user: event.user,
        state: UserStates.signedOut,
      ));
      // otherwise the user must have signed in
    } else {
      emit(UserUpdate(
        user: event.user,
        state: UserStates.signedIn,
      ));
    }
  }

  // ========================= Event Handlers ========================== //

  /*  
  1). Sign in Anonymously 
    i - This handler utilizes the intermediary service function `signInAnon` -> User?
        we described under /lib/services/auth.dart. 

    ii - on Error emits the state update with error status and error message for use on client side.
        handles FirebaseAuthException: 
      * operation-not-allowed 
      ? when anon sign in is not enabled in firebase

    returns : void

  */
  FutureOr<void> _signInUserAnonHandler(
      UserSignInAnonymously event, Emitter<UserState> emit) async {
    try {
      emit(UserUpdate(user: state.user, state: UserStates.processing));
      // i).
      await _auth.signInAnon();

      // ii).
    } on FirebaseAuthException catch (error) {
      emit(UserUpdate(user: state.user, state: UserStates.idle));
      emit(UserUpdate(state: UserStates.error, error: error));
    }
  }

  /* 
  2). LogOut the User 
      Logs out the current User that is signed in to our firebase auth instance

    i- Utilizes service function `logout` -> bool

    ii -  on Error emits the state update with error status and error message for use on client side.

    returns bool
  */
  FutureOr<void> _signOutUserHandler(UserSignOut event, Emitter<UserState> emit) async {
    try {
      emit(UserUpdate(user: state.user, state: UserStates.processing));

      // i.
      await _auth.logout();

      // ii.
    } on FirebaseAuthException catch (e) {
      emit(UserUpdate(user: state.user, state: UserStates.idle));
      emit(UserUpdate(state: UserStates.error, error: e));
    }
  }

  /* 
    # Register User With Email And Password Handler
    - utilizes the service function `registerWithEmailAndPassword` -> User?

     A [FirebaseAuthException] maybe thrown with the following error code:
     * email-already-in-use
     * invalid-email
     * operation-not-allowed:
      ? Thrown if email/password accounts are not enabled. Enable 
      ? email/password accounts in the Firebase Console, under the Auth tab.
     *  weak-password:
      ? Thrown if the password is not strong enough.
   */
  FutureOr<void> _registerUserWithEmailAndPassHandler(
      RegisterUserWithEmailAndPassword event, Emitter<UserState> emit) async {
    // Input Validation Can be done here and if not valid can be thrown a custom error
    // which on frontend can be caught and handeled

    try {
      emit(UserUpdate(user: state.user, state: UserStates.processing));

      // i.
      if (kDebugMode) {
        print('Registering user with: \nEmail: ${event.email}\nPass: ${event.password}\n');
      }

      User? user = await _auth.registerWithEmailAndPassword(event.email, event.password);

      if (user != null) {
        emit(UserUpdate(user: state.user, state: UserStates.idle));

        // signing in autonomously
        add(UserSignInWithEmailAndPassword(email: user.email!, password: event.password));
      }

      // Incase of error while registering on Signing in
    } on FirebaseAuthException catch (e) {
      emit(UserUpdate(user: state.user, state: UserStates.idle));
      emit(UserUpdate(state: UserStates.error, error: e));
    }
  }

  /* 
    # Signs in User With Email And Password Handler
    - utilizes the service function `signInWithEmailAndPassword` -> User?

    Handlers FirebaseAuthException:
    * invalid-email:
      ? Thrown if the email address is not valid.
    * user-disabled:
      ? Thrown if the user corresponding to the given email has been disabled.
    * user-not-found:
      ? Thrown if there is no user corresponding to the given email.
    * wrong-password:
      ? Thrown if the password is invalid for the given email, or the account corresponding to the email does not have a password set.
  */
  FutureOr<void> _signInUserWithEmailAndPassHandler(
      UserSignInWithEmailAndPassword event, Emitter<UserState> emit) async {
    emit(UserUpdate(user: state.user, state: UserStates.processing));

    try {
      if (kDebugMode) {
        print('Signing in user with: \nEmail: ${event.email}\nPass: ${event.password}\n');
      }
      // i.
      await _auth.signInWithEmailAndPassword(event.email, event.password);

      // ii. Incase of error while registering on Signing in
    } on FirebaseAuthException catch (e) {
      emit(UserUpdate(user: state.user, state: UserStates.idle));
      emit(UserUpdate(state: UserStates.error, error: e));
    }
  }
}
