import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ilayki_web/blocs/authenticate/authenticate_bloc.dart';

import '../../blocs/chat/chat_bloc.dart';
import '../../models/user.dart';
import '../models/message.dart';
import '../widgets/chat_message.dart';

class ChatroomPage extends StatefulWidget {
  static const routeName = '/chat';
  final User otherUser;

  const ChatroomPage({super.key, required this.otherUser});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage>
    with WidgetsBindingObserver {
  late String currentUser;
  late ChatBloc chatBloc;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();

  FocusNode messageNode = FocusNode();
  @override
  void didChangeDependencies() {
    currentUser = context.read<AuthenticateBloc>().state.user!.uid;
    chatBloc = context.read<ChatBloc>();

    chatBloc.add(InitChatEvent(currentUser, widget.otherUser.uid));

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    chatBloc.add(const DisposeChat());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage:
                          Image.network(widget.otherUser.pfp, fit: BoxFit.cover)
                              .image,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(widget.otherUser.displayName),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () => _controller.animateTo(
                        _controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastEaseInToSlowEaseOut,
                      ),
                  icon: const Icon(Icons.keyboard_double_arrow_up))
            ],
          ),

          /* Chat Body */
          body: Stack(
            children: [
              /* Chat Messages */
              if (state.messages == null) ...[
                const Center(
                  child: CircularProgressIndicator(),
                )
              ] else if (state.messages!.isEmpty) ...[
                Center(
                  child: Text(
                      "This is the beginning of your conversation with ${widget.otherUser.displayName}"),
                )
              ] else ...[
                ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  reverse: true,
                  controller: _controller,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 42,
                    bottom: 100,
                  ),
                  itemBuilder: (context, index) =>
                      ChatMessage(message: state.messages![index]),
                  itemCount: state.messages!.length,
                ),
              ],
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Message",
                              prefixIcon: Icon(Icons.edit_square),
                            ),
                            focusNode: messageNode,
                            onSubmitted: (text) {
                              if (_messageController.text.isNotEmpty) {
                                context.read<ChatBloc>().add(
                                      SendMessageEvent(
                                        Message(
                                          senderUid: currentUser,
                                          receiverUid: widget.otherUser.uid,
                                          timestamp: DateTime.now(),
                                          content:
                                              _messageController.text.trim(),
                                        ),
                                      ),
                                    );
                              }
                              _messageController.clear();
                              messageNode.requestFocus();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () {
                            if (_messageController.text.isNotEmpty) {
                              context.read<ChatBloc>().add(
                                    SendMessageEvent(
                                      Message(
                                        senderUid: currentUser,
                                        receiverUid: widget.otherUser.uid,
                                        timestamp: DateTime.now(),
                                        content: _messageController.text.trim(),
                                      ),
                                    ),
                                  );
                            }

                            // after sending the event clear the text
                            _messageController.clear();
                          },
                          style: IconButton.styleFrom(
                            minimumSize: const Size.fromRadius(32),
                            backgroundColor:
                                Theme.of(context).colorScheme.inversePrimary,
                          ),
                          label: const Text("Send"),
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
