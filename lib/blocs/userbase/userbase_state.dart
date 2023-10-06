part of 'userbase_bloc.dart';

@immutable
sealed class UserbaseState {
  final List<model.User>? users;

  const UserbaseState({this.users});
}

final class UserbasePopulate extends UserbaseState {
  const UserbasePopulate({super.users});
}

final class UserbaseInit extends UserbaseState {}

final class UserbaseReset extends UserbaseState {}
