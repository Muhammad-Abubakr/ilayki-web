import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/models/message.dart';
import 'package:ilayki/widgets/chat_message.dart';

import '../blocs/chat/chat_bloc.dart';
import '../blocs/online/online_cubit.dart';
import '../models/user.dart';

class ChatRoomScreen extends StatefulWidget {
  // route name
  static const routeName = '/chatroom';

  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  /* Params */
  late String currentUser;
  late User secondUser;

  /* Controllers */
  final TextEditingController _messageController = TextEditingController();

  @override
  void didChangeDependencies() {
    /* Accessing parameters sent using route navigator */
    var args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    currentUser = args["currentUser"] as String;
    secondUser = args["owner"] as User;

    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    /* dispose the chat room */
    context.read<ChatBloc>().add(const DisposeChat());

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    /* force updating the chats screen */
    final chatBloc = context.watch<ChatBloc>();

    /* intialize the chat room */
    chatBloc.add(InitChatEvent(currentUser, secondUser.uid));

    return Scaffold(
      /* Chat Screen App Bar */
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0.spMax),
          leading: Container(
            margin: EdgeInsets.symmetric(vertical: 6.0.spMax),
            padding: EdgeInsets.all(2.0.spMax),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.sw),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.sw),
              child: Image.network(secondUser.photoURL, fit: BoxFit.cover),
            ),
          ),
          // Username
          title: Text(secondUser.name),
          // online status
          trailing: BlocBuilder<OnlineCubit, OnlineState>(
            builder: (context, state) {
              return CircleAvatar(
                radius: 24.r,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: state.onlineUsers.contains(secondUser.uid)
                      ? Colors.green
                      : Colors.redAccent,
                ),
              );
            },
          ),
        ),
      ),

      /* Chat Body */
      body: Stack(
        children: [
          /* Chat Messages */
          ListView.builder(
            padding: EdgeInsets.only(
              left: 8.0.spMax,
              right: 8.0.spMax,
              top: 12.0.spMax,
              bottom: 64.spMax,
            ),
            itemBuilder: (context, index) =>
                ChatMessage(message: chatBloc.state.messages[index]),
            itemCount: chatBloc.state.messages.length,
          ),

          /* Message Field */
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 4.0.spMax,
                horizontal: 8.0.spMax,
              ),
              width: 100.sw,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border.symmetric(
                  horizontal: BorderSide(
                    color: Colors.grey,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 0.8.sw,
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message here',
                        prefixIcon: Icon(Icons.edit_square),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton.filled(
                      onPressed: () {
                        context.read<ChatBloc>().add(
                              SendMessageEvent(
                                Message(
                                    sender: context.read<UserBloc>().state.user!.uid,
                                    receiver:
                                        context.read<UserBloc>().state.user!.uid == currentUser
                                            ? secondUser.uid
                                            : currentUser,
                                    time: DateTime.now(),
                                    content: _messageController.text),
                              ),
                            );

                        // after sending the event clear the text
                        _messageController.clear();
                      },
                      icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
