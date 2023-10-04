import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/blocs/email_verificaton/email_verification_cubit.dart';
import 'package:ilayki/services/firebase/auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart' as my_user;

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  /* ================================ Fields ================================ */
  /* Firebase Storage Instance Reference (root) */
  final storage = FirebaseStorage.instance.ref();
  /* Firebase Realtime database Instance Reference (root) */
  final database = FirebaseDatabase.instance.ref();
  /* linking to our service cursor `AuthService` we created under /lib/srevices/auth.dart
  this will be used to call all the intermediary service calls to FirebaseAuth */
  late final AuthService _auth;
  /* To tell the email verification cubit that I have sent the link, and now it's up to you
  * to handle the rest of the verification process and client queries form frontend */
  final EmailVerificationCubit emailVerificationCubit;

  /* ================================ UserBloc constructor ================================ 

     Extends the Bloc with event type UserEvent and state type UserState
     {may need to look into dart streams for a better understanding of how it works}
     [https://www.youtube.com/watch?v=w6XWjpBK4W8&list=PLptHs0ZDJKt_T-oNj_6Q98v-tBnVf-S_o]

     Above is the link to a great playlist for flutter_bloc by flutterly
   */
  UserBloc(this.emailVerificationCubit)
      : super(const UserInitial(state: UserStates.signedOut)) {
    _auth = AuthService();

    // =============== Subscribing to Firebase User Stream ================ //
    _auth.subscribe.listen((element) => add(_UserUpdateEvent(element)));

    // =============== Hooking Handlers ================ //
    // PRIVATE
    on<_UserUpdateEvent>(_subscriptionHandler);

    // CLIENT
    on<UserSignInAnonymously>(_signInUserAnonHandler);
    on<UserNameUpdate>(_userNameUpdateHandler);
    on<EmailVerification>(_emailVerificationHandler);
    on<UserSignInWithGoogle>(_signInWithGoogle);
    on<RegisterUserWithEmailAndPassword>(_registerUserWithEmailAndPassHandler);
    on<UserSignInWithEmailAndPassword>(_signInUserWithEmailAndPassHandler);
    on<UserSignOut>(_signOutUserHandler);
    on<UserPfpUpdate>(_userPfpUpdateHandler);
  }

  /* 
    Subscription Handler
   */
  FutureOr<void> _subscriptionHandler(
      _UserUpdateEvent event, Emitter<UserState> emit) {
    // updates the Bloc about the change in user state from the firebase subscription
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
  FutureOr<void> _signOutUserHandler(
      UserSignOut event, Emitter<UserState> emit) async {
    try {
      // i.
      await _auth.logout();

      // ii.
    } on FirebaseAuthException catch (e) {
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
        print(
            'Registering user with: \nEmail: ${event.email}\nPass: ${event.password} as ${event.role}\n');
      }

      User? user =
          await _auth.registerWithEmailAndPassword(event.email, event.password);

      if (user != null) {
        /* Updating the user */
        await user.updateDisplayName(event.fullName);

        /* Storing the image */
        // Getting the reference
        final imageRef = storage.child('pfps/${user.uid}');
        await imageRef.putFile(File(event.xFile.path));
        await user.updatePhotoURL(await imageRef.getDownloadURL());

        final idCardRef = storage.child('ids/${user.uid}');
        await idCardRef.putFile(File(event.idCard.path));

        /* Add the User to users collection in realtime database */
        late final DatabaseReference userRef;

        if (event.role == UserRoles.customer) {
          userRef = database.child('users/customers/${user.uid}');
        } else {
          userRef = database.child('users/sellers/${user.uid}');
        }

        /* Create user at the usersRef */
        await userRef.set(
          my_user.User(
            fullName: event.fullName,
            idCard: await idCardRef.getDownloadURL(),
            gender: event.gender,
            address: event.address,
            city: event.city,
            phoneNumber: event.phoneNumber,
            photoURL: await imageRef.getDownloadURL(),
            uid: user.uid,
            role: event.role,
          ).toJson(),
        );
        add(EmailVerification(user));
        emit(UserUpdate(
          state: UserStates.registered,
          user: user,
        ));
      }

      // In case of error while registering on Signing in
    } on FirebaseException catch (e) {
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
        print(
            'Signing in user with: \nEmail: ${event.email}\nPass: ${event.password}\n');
      }
      // i.
      await _auth.signInWithEmailAndPassword(event.email, event.password);

      // ii. Incase of error while registering on Signing in
    } on FirebaseAuthException catch (e) {
      emit(UserUpdate(state: UserStates.error, error: e));
    }
  }

  /*
    # User Sign-In With Google handler

    Handlers FirebaseAuthException:
    * User-Disabled
      ? thrown if the relevant authentication method is not enabled
   */
  FutureOr<void> _signInWithGoogle(
      UserSignInWithGoogle event, Emitter<UserState> emit) async {
    try {
      emit(UserUpdate(user: state.user, state: UserStates.processing));
      // i).
      await _auth.signInWithGoogle();

      // ii).
    } on FirebaseAuthException catch (error) {
      emit(UserUpdate(state: UserStates.error, error: error));
    }
  }

  /*
    # Updates User photoURL in Firebase User instance

    i). Replaces the photo file in the storage path for the user
    ii). Updates the photo url in the user instance of firebase
    iii). catches errors incase any
   */
  FutureOr<void> _userPfpUpdateHandler(
      UserPfpUpdate event, Emitter<UserState> emit) async {
    try {
      // i).

      /* Update  PhotoURL */

      /* Storing the image */
      // Getting the reference (child) to the user uid
      final imageRef = storage.child('pfps/${state.user?.uid}');

      /// updating the photoURL
      // deleting
      try {
        await imageRef.delete();
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      // updating
      final imageSnapshot = await imageRef.putFile(File(event.xFile.path));

      /* Updating the user */
      await state.user
          ?.updatePhotoURL(await imageSnapshot.ref.getDownloadURL());

      /* Updating reference to user profile pic in the users collection in database */
      // getting the reference
      DatabaseReference userRef =
          database.child("users/customers/${state.user?.uid}");
      if (!(await userRef.get()).exists) {
        userRef = database.child('users/sellers/${state.user?.uid}');
      }

      // parsing and updating the user modal
      final user =
          my_user.User.fromJson((await userRef.get()).value.toString());
      final updatedUser =
          user.copyWith(photoURL: await imageSnapshot.ref.getDownloadURL());

      // setting the new model for the user in the database
      userRef.set(updatedUser.toJson());

      // emit the user state, that the user is updated
      emit(UserUpdate(
          user: FirebaseAuth.instance.currentUser, state: UserStates.updated));
      // ii).
    } on FirebaseAuthException catch (error) {
      emit(UserUpdate(state: UserStates.error, error: error));
    }
  }

  FutureOr<void> _userNameUpdateHandler(
      UserNameUpdate event, Emitter<UserState> emit) async {
    try {
      /* Updating the user */
      await state.user?.updateDisplayName(event.name);

      /* Updating reference to user profile pic in the users collection in database */
      // getting the reference
      DatabaseReference userRef =
          database.child("users/customers/${state.user?.uid}");
      if (!(await userRef.get()).exists) {
        userRef = database.child('users/sellers/${state.user?.uid}');
      }

      // parsing and updating the user modal
      final user =
          my_user.User.fromJson((await userRef.get()).value.toString());
      final updatedUser = user.copyWith(fullName: event.name);

      // setting the new model for the user in the database
      userRef.set(updatedUser.toJson());

      // emit the user state, that the user is updated
      emit(UserUpdate(
          user: FirebaseAuth.instance.currentUser, state: UserStates.updated));
      // ii).
    } on FirebaseAuthException catch (error) {
      emit(UserUpdate(state: UserStates.error, error: error));
    }
  }

  /* Called in case of user registering first time, for email verification */
  FutureOr<void> _emailVerificationHandler(
      EmailVerification event, Emitter<UserState> emit) async {
    if (!event.user.emailVerified) {
      await _auth.verifyEmail(event.user);
      // telling the email verification cubit about the sent verification email
      emailVerificationCubit.verificationPending();
    }
  }
}
