part of 'userchat_cubit.dart';

abstract class UserchatState {
  final List<String> chatRefs;

  const UserchatState(this.chatRefs);
}

class UserchatInit extends UserchatState {
  UserchatInit() : super(List.empty(growable: true));
}

class UserchatReset extends UserchatState {
  UserchatReset() : super(List.empty(growable: true));
}

class UserchatPopulate extends UserchatState {
  const UserchatPopulate(super.chatRefs);
}
