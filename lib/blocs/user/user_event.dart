// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

/* Following events lie under the UserEvent interface
   because:
    - That is how bloc recognizes the events belonging to a specific bloc
    - That is how bloc differentiates between the events and specify which bloc they belong to

  Another responsibility of the events is to stick the data relative to that event,
  and provide it to the bloc handlers for whatever they want to do with it. 
 */

/* When the user tries to register with email and password this event is fired 
   takes two named argument:
    1. email : String
    2. password : String
*/
class RegisterUserWithEmailAndPassword extends UserEvent {
  final String email;
  final String password;

  RegisterUserWithEmailAndPassword({required this.email, required this.password});
}

/* When the user tries to sign in with email and password this event is fired 
   takes two named argument:
    1. email : String
    1. password : String
*/
class UserSignInWithEmailAndPassword extends UserEvent {
  final String email;
  final String password;

  UserSignInWithEmailAndPassword({required this.email, required this.password});
}

/* When the user tries to sign in anonymously this event is fired 
   takes no arguments
*/
class UserSignInAnonymously extends UserEvent {}

/* When the user tries to sign out this event is fired,
   takes no arguments
 */
class UserSignOut extends UserEvent {}

/* 
  Private Event (to bloc)
  When the user tries to sign out this event is fired,
   takes no arguments
 */
class _UserUpdateEvent extends UserEvent {
  final User? user;

  _UserUpdateEvent(this.user);
}
