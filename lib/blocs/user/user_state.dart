part of 'user_bloc.dart';

/* Implementing an Enum to reflect the state of UserBloc
   This helps in implementing features like loading widgets, error dialogs etc.
 */
enum UserStates {
  initialized,
  updated,
  signedOut,
  signedIn,
  processing,
  registered,
  error,
}

/* User Roles in the application */
enum UserRoles {
  customer,
  seller,
}

/* extending package Equatable for deep comparision between objects,
   incase if we used `extends` we can also use EquatableMixin using `with`
 */
@immutable
abstract class UserState {
  // Firebase User instance
  final User? user;
  final UserStates state;
  final FirebaseException? error;

  // Constructor for UserState,
  // takes in one Named Parameter: user of type FirebaseAuth.User
  const UserState({required this.user, required this.state, this.error});
}

/* Initial State of the User Bloc */
class UserInitial extends UserState {
  const UserInitial(
      {User? user, required UserStates state, FirebaseAuthException? error})
      : super(user: user, state: state, error: error);
}

/* Updated State of the User Bloc */
class UserUpdate extends UserState {
  const UserUpdate(
      {User? user, required UserStates state, FirebaseException? error})
      : super(user: user, state: state, error: error);
}
