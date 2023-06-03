part of 'userchat_cubit.dart';

abstract class UserchatState extends Equatable {
  final List<String> chatRefs;

  const UserchatState(this.chatRefs);

  @override
  List<Object> get props => [chatRefs];
}

class UserchatInitial extends UserchatState {
  const UserchatInitial(super.chatRefs);
}

class UserchatUpdate extends UserchatState {
  const UserchatUpdate(super.chatRefs);
}
