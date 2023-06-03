import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/blocs/userchat/userchat_cubit.dart';
import 'package:ilayki/screens/chat_room_screen.dart';

import '../models/user.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /* Userbase (to search other) */
    final UserbaseCubit userbaseCubit = context.read<UserbaseCubit>();

    final OnlineCubit onlineCubit = context.watch<OnlineCubit>();

    /* User Chats */
    final UserchatCubit userchatCubit = context.watch<UserchatCubit>();
    final List<String> refs = userchatCubit.state.chatRefs;

    /* my uid */
    final String myUID = context.read<UserBloc>().state.user!.uid;

    // get the other user uid
    User getOther(int index) {
      List<String> splitted = refs[index].split('+');

      return userbaseCubit.getUser(splitted[splitted[0] == myUID ? 1 : 0]);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 4.spMax),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        User otherUser = getOther(index);

        return ListTile(
          onTap: () => Navigator.of(context).pushNamed(ChatRoomScreen.routeName, arguments: {
            "currentUser": myUID,
            "itemOwner": otherUser,
          }),
          leading: Container(
            margin: EdgeInsets.symmetric(vertical: 6.0.spMax),
            padding: EdgeInsets.all(2.0.spMax),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.sw),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.sw),
              child: Image.network(otherUser.photoURL, fit: BoxFit.cover),
            ),
          ),
          title: Text(otherUser.name),
          trailing: CircleAvatar(
            radius: 24.r,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor:
                  onlineCubit.isOnline(otherUser.uid) ? Colors.green : Colors.redAccent,
            ),
          ),
        );
      },
      itemCount: refs.length,
    );
  }
}
