part of 'userbase_bloc.dart';

@immutable
sealed class UserbaseEvent {}

class InitEvent extends UserbaseEvent {}

class AddUserEvent extends UserbaseEvent {
  final String? displayName;
  final String? email;
  final String? pfp;

  AddUserEvent({this.displayName, this.email, this.pfp});
}

class UpdateUserEvent extends UserbaseEvent {
  final String? displayName;
  final String? email;
  final String? pfp;

  UpdateUserEvent({this.displayName, this.email, this.pfp});
}

class DeleteUserEvent extends UserbaseEvent {
  final String uid;

  DeleteUserEvent({required this.uid});
}
