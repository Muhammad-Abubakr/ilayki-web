part of 'userbase_cubit.dart';

abstract class UserbaseState extends Equatable {
  final List<User>? customer;
  final List<User>? seller;

  const UserbaseState({
    required this.customer,
    required this.seller,
  });

  @override
  List<Object?> get props => [customer, seller];
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
