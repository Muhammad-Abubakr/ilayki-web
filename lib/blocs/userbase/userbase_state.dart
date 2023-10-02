part of 'userbase_cubit.dart';

abstract class UserbaseState {
  final List<User> customer;
  final List<User> seller;

  const UserbaseState({
    required this.customer,
    required this.seller,
  });
}

class UserbaseInitial extends UserbaseState {
  const UserbaseInitial({
    required super.customer,
    required super.seller,
  });
}

class UserbaseUpdate extends UserbaseState {
  const UserbaseUpdate({
    required super.customer,
    required super.seller,
  });
}
