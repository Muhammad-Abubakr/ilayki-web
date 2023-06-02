import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatInitial(messages: [])) {
    // get the users
    // getUsers();

    /* Event Handlers */
    on<ChatEvent>((event, emit) {});
  }
}
