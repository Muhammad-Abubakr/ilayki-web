part of 'chat_bloc.dart';

abstract class ChatState {
  final List<Message>? messages;

  const ChatState({this.messages});
}

class ChatInit extends ChatState {
  ChatInit() : super(messages: List.empty(growable: true));
}

class ChatReset extends ChatState {
  ChatReset() : super(messages: List.empty(growable: true));
}

class ChatPopulate extends ChatState {
  const ChatPopulate({super.messages});
}
