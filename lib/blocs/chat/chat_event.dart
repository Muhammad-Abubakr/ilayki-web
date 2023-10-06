part of 'chat_bloc.dart';

abstract class ChatEvent {
  const ChatEvent();
}

/* Initiate Chat event 
   * Takes two User Id's as parameters.
*/
class InitChatEvent extends ChatEvent {
  final String currentUser;
  final String otherUser;

  const InitChatEvent(this.currentUser, this.otherUser);
}

/* Send Message event 
   * Takes one Message as parameter
*/
class SendMessageEvent extends ChatEvent {
  final Message message;

  const SendMessageEvent(this.message);
}

/* Update Messages event 
   * Takes List of Messages as parameter
   * used because 
*/
class _UpdateMessagesEvent extends ChatEvent {
  final List<Message> messages;

  const _UpdateMessagesEvent(this.messages);
}

/* Dispose Chat event */
class DisposeChat extends ChatEvent {
  const DisposeChat();
}
