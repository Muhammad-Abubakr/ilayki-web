import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _chatsRef = FirebaseDatabase.instance.ref("chats");
  late DatabaseReference _chatRoomRef;

  ChatBloc() : super(ChatInit()) {
    on<InitChatEvent>(_initiationHandler);
    on<_UpdateMessagesEvent>(_streamEmissionHandler);
    on<SendMessageEvent>(_sendMessageHandler);
    on<DisposeChat>(_dispose);
  }

  FutureOr<void> _initiationHandler(InitChatEvent event, Emitter<ChatState> emit) async {
    _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.otherUser}');

    if ((await _chatRoomRef.get()).exists) {
      _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.otherUser}');
    } else {
      _chatRoomRef = _chatsRef.child('${event.otherUser}+${event.currentUser}');
      if ((await _chatRoomRef.get()).exists) {
        _chatRoomRef = _chatsRef.child('${event.otherUser}+${event.currentUser}');
      } else {
        _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.otherUser}');
      }
    }

    _chatRoomRef.onValue.listen((event) {
      final List<Message> messages = List.empty(growable: true);
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        for (var msg in data.values) {
          final parsedMessage = Message.fromJson(msg.toString());
          messages.add(parsedMessage);
        }
        add(_UpdateMessagesEvent(messages));
      }
    });
  }

  FutureOr<void> _sendMessageHandler(SendMessageEvent event, Emitter<ChatState> emit) {
    final messageRef = _chatRoomRef.push();
    messageRef.set(event.message.toJson());
  }

  FutureOr<void> _streamEmissionHandler(_UpdateMessagesEvent event, Emitter<ChatState> emit) {
    event.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final messages = event.messages.reversed.toList();

    emit(ChatPopulate(messages: messages));
  }

  FutureOr<void> _dispose(DisposeChat event, Emitter<ChatState> emit) {
    emit(ChatReset());
  }

  FutureOr<Message> getLatestMessage(String currentUser, String otherUser) async {
    _chatRoomRef = _chatsRef.child('$currentUser+$otherUser');

    if ((await _chatRoomRef.get()).exists) {
      _chatRoomRef = _chatsRef.child('$currentUser+$otherUser');
    } else {
      _chatRoomRef = _chatsRef.child('$otherUser+$currentUser');
      if ((await _chatRoomRef.get()).exists) {
        _chatRoomRef = _chatsRef.child('$otherUser+$currentUser');
      } else {
        _chatRoomRef = _chatsRef.child('$currentUser+$otherUser');
      }
    }

    final snapshot = await _chatRoomRef.limitToLast(1).get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    return Message.fromJson(data!.values.first.toString());
  }
}
