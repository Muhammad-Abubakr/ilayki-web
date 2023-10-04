import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/screens/home/user_items_page.dart';

import '../blocs/online/online_cubit.dart';
import '../blocs/user/user_bloc.dart';
import '../models/user.dart';
import '../screens/chat/chat_room_screen.dart';

class UserOverview extends StatelessWidget {
  final User user;

  const UserOverview({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(UserItems.routeName, arguments: {
        "user": user,
      }),
      child: Card(
        elevation: 8,
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            /* Image for the item */
            LayoutBuilder(
              builder: (_, constraints) => FittedBox(
                fit: BoxFit.contain,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    user.photoURL,
                    fit: BoxFit.cover,
                    width: constraints.maxWidth,
                    height: 480.h,
                  ),
                ),
              ),
            ),
            /* Item and Owner Details */
            ListTile(
              // user pfp
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 64.r,
                    backgroundImage: Image.network(user.photoURL).image,
                  ),
                  BlocBuilder<OnlineCubit, OnlineState>(
                    builder: (context, state) {
                      return CircleAvatar(
                        radius: 20.r,
                        backgroundColor: state.onlineUsers.contains(user.uid)
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      );
                    },
                  ),
                ],
              ),

              // item name as title
              title: Text(user.fullName),

              // item price as subtitle
              // subtitle: const Text('rating here'),

              // add to basket button
              trailing: IconButton(
                onPressed: () {
                  // go to the chat page, send the two users as arguments, chat will be
                  // intialized there and end there
                  Navigator.of(context)
                      .pushNamed(ChatRoomScreen.routeName, arguments: {
                    "currentUser": context.read<UserBloc>().state.user!.uid,
                    "itemOwner": user,
                  });
                },
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.chat_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
