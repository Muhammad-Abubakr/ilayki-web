import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/userchat/userchat_cubit.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../blocs/authenticate/authenticate_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/userbase/userbase_bloc.dart';
import 'chatroompage.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  Message? latestMessage;

  late UserbaseBloc userbaseBloc;
  late UserchatCubit userchatCubit;
  late List<String> refs;
  late String currentUid;

  final List<User> others = List.empty(growable: true);
  List<Message> lastMessages = List.empty(growable: true);

  User getOther(String ref) {
    List<String> splitted = ref.split('+');

    return userbaseBloc.getUser(splitted[splitted[0] == currentUid ? 1 : 0]);
  }

  // get last message
  Future<Message> getLastMessage(String other) async {
    return await context.read<ChatBloc>().getLatestMessage(currentUid, other);
  }

  @override
  void didChangeDependencies() {
    userbaseBloc = context.read<UserbaseBloc>();
    userchatCubit = context.watch<UserchatCubit>();
    refs = userchatCubit.state.chatRefs;
    currentUid = context.read<AuthenticateBloc>().state.user!.uid;

    for (var ref in refs) {
      others.add(getOther(ref));
    }

    () async {
      List<Message> container = List.empty(growable: true);
      for (var user in others) {
        container.add(await getLastMessage(user.uid));
      }

      setState(() => lastMessages = container);
    }();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: refs.isEmpty
          ? const Center(
              child: Text("Your chats will appear here"),
            )
          : lastMessages.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    User otherUser = others[index];
                    Message lastMessage = lastMessages[index];

                    return Card(
                      elevation: 2,
                      child: ListTile(
                        key: Key(refs[index]),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ChatroomPage(otherUser: otherUser))),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                              backgroundImage: Image.network(otherUser.pfp,
                                      fit: BoxFit.cover)
                                  .image,
                            ),
                          ),
                        ),
                        title: Text(
                          otherUser.displayName,
                        ),
                        subtitle: Text(
                          "${lastMessage.senderUid == currentUid ? "You" : otherUser.displayName}: ${lastMessage.content}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          lastMessage.timestamp.toIso8601String(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: refs.length,
                ),
    );
  }
}
