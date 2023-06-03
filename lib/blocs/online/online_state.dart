part of 'online_cubit.dart';

abstract class OnlineState extends Equatable {
  final List<String> onlineUsers;

  const OnlineState(this.onlineUsers);

  @override
  List<Object> get props => [onlineUsers];
}

class OnlineInitial extends OnlineState {
  const OnlineInitial(super.onlineUsers);
}

class OnlineUpdated extends OnlineState {
  const OnlineUpdated(super.onlineUsers);
}
