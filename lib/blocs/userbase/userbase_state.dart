part of 'userbase_cubit.dart';

abstract class UserbaseState extends Equatable {
  final List<User> userbase;

  const UserbaseState(this.userbase);

  @override
  List<Object> get props => [userbase];
}

class UserbaseInitial extends UserbaseState {
  const UserbaseInitial(super.userbase);
}

class UserbaseUpdate extends UserbaseState {
  const UserbaseUpdate(super.userbase);
}
