import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /* Database Chats reference */
  final _chatsRef = FirebaseDatabase.instance.ref("chats");

  /* chat room ref (userNot+userOne)*/
  late DatabaseReference _chatRoomRef;

  /* chat room stream ref */
  late StreamSubscription _chatStreamRef;

  ChatBloc() : super(const ChatInitial(messages: [])) {
    /* Event Handlers */
    on<InitChatEvent>(_initiationHandler);
    on<_UpdateMessagesEvent>(_streamEmissionHandler);
    on<SendMessageEvent>(_sendMessageHandler);
    on<DisposeChat>(_dispositionHandler);
  }

  /* Initiation Handler */
  FutureOr<void> _initiationHandler(InitChatEvent event, Emitter<ChatState> emit) async {
    /* create a reference to the chat room between two users */
    _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.itemOwner}');

    /* Check if the room exists */
    if ((await _chatRoomRef.get()).exists) {
      // then the chat room ref remains the same
      _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.itemOwner}');
    } else {
      if (kDebugMode) {
        print('Room: ${event.currentUser}+${event.itemOwner} does not exist');
      }
      _chatRoomRef = _chatsRef.child('${event.itemOwner}+${event.currentUser}');

      // if this ref exists switch the chatRoomRef to this ref
      if ((await _chatRoomRef.get()).exists) {
        _chatRoomRef = _chatsRef.child('${event.itemOwner}+${event.currentUser}');
      } else {
        _chatRoomRef = _chatsRef.child('${event.currentUser}+${event.itemOwner}');
      }

      if (kDebugMode) {
        print(
            'Room: ${event.itemOwner}+${event.currentUser} does not exist. Going with ${event.currentUser}+${event.itemOwner}');
      }
    }
    // otherwise keep going with first reference as this will be the first time
    // chat between both users will be happening

    ///? Now that we are done with the room reference let's get all the chat messages we have
    /// inside the reference our Bloc chose
    //* Messages Container
    final List<Message> messages = List.empty(growable: true);

    _chatStreamRef = _chatRoomRef.onValue.listen((event) {
      // extract the data
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if the data exists, populate the chat
      if (data != null) {
        for (var msg in data.values) {
          // parse the message
          final parsedMessage = Message.fromJson(msg.toString());

          //add the parsed messages to container
          messages.add(parsedMessage);
        }
        // once all the messages have been read, intialization completes after emition of them
        // so
        add(_UpdateMessagesEvent(messages));
      }
    });
  }

  /* Handles the sending messages event */
  FutureOr<void> _sendMessageHandler(SendMessageEvent event, Emitter<ChatState> emit) {
    // create a push reference for the new message in the database
    final messageRef = _chatRoomRef.push();

    // set the message json as value
    messageRef.set(event.message.toJson());
  }

  // disposition
  FutureOr<void> _dispositionHandler(DisposeChat event, Emitter<ChatState> emit) async {
    // disposing open streams
    _chatStreamRef.cancel();

    // clearing chat state
    emit(const ChatUpdates(messages: []));

    if (kDebugMode) {
      print('Closing Chat Stream. Ref: $_chatRoomRef');
    }
  }

  /* Handles the emissions from the stream */
  FutureOr<void> _streamEmissionHandler(_UpdateMessagesEvent event, Emitter<ChatState> emit) {
    // order the messages based on timestamp
    event.messages.sort((a, b) => a.time.compareTo(b.time));

    emit(ChatUpdates(messages: event.messages));
  }
}
