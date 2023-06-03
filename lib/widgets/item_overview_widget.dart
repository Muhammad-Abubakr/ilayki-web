import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/basket/basket_cubit.dart';
import 'package:ilayki/blocs/online/online_cubit.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';

import '../models/item.dart';
import '../models/user.dart';
import '../screens/chat/chat_room_screen.dart';

class ItemOverview extends StatelessWidget {
  final Item item;
  final User owner;
  final int idx;

  const ItemOverview({super.key, required this.idx, required this.item, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  item.image,
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
                  backgroundImage: Image.network(owner.photoURL).image,
                ),
                BlocBuilder<OnlineCubit, OnlineState>(
                  builder: (context, state) {
                    return CircleAvatar(
                      radius: 20.r,
                      backgroundColor: state.onlineUsers.contains(owner.uid)
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    );
                  },
                ),
              ],
            ),

            // item name as title
            title: Text(item.name),

            // item price as subtitle
            subtitle: Text('${item.price}'),

            // add to basket button
            trailing: LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: constraints.maxWidth * 0.35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        // go to the chat page, send the two users as arguments, chat will be
                        // intialized there and end there
                        Navigator.of(context).pushNamed(ChatRoomScreen.routeName, arguments: {
                          "currentUser": context.read<UserBloc>().state.user!.uid,
                          "itemOwner": owner,
                        });
                      },
                      color: Theme.of(context).primaryColor,
                      icon: const Icon(Icons.chat_rounded),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        // add the item to basket
                        context.read<BasketCubit>().addItem(item);

                        // show basket added snackbar
                        ScaffoldMessenger.of(context).clearSnackBars();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).primaryColor,
                            content: Text(
                              '${item.name} added to basket',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_basket_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
