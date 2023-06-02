part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  final List<Message>? messages;

  const ChatState({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial({required super.messages});
}
