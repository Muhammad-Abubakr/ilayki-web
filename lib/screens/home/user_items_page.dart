import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../blocs/user/user_bloc.dart';
import '../../blocs/wares/wares_cubit.dart';
import '../../models/item.dart';
import '../../models/user.dart';
import '../../widgets/item_overview_widget.dart';
import '../chat/chat_room_screen.dart';

class UserItems extends StatefulWidget {
  // routeName
  static const routeName = '/user-items';

  const UserItems({super.key});

  @override
  State<UserItems> createState() => _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  // get the user for which we need items
  late final Map<String, dynamic> args;
  late final User user;

  // wares Cubit
  late WaresState state;
  List<Item> wares = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    // get the owner of the items
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    user = args["user"] as User;

    // get the wares cubit
    state = context.watch<WaresCubit>().state;

    // update the wares
    wares = state.wares.where((element) => element.owner == user.uid).toList();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // orientation
    context.watch<WaresCubit>().state;
    final isLandscape = MediaQuery.of(context).orientation.index == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name,
            style: TextStyle(color: Theme.of(context).primaryColor)),
        actions: [
          IconButton(
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
        ],
      ),
      body: wares.isEmpty
          ? Center(
              child: Text(
                  AppLocalizations.of(context)!.nothingToShowHereForTheMoment),
            )
          /* otherwise build items */
          : ListView.separated(
              padding: isLandscape
                  ? EdgeInsets.symmetric(horizontal: 0.25.sw, vertical: 32.h)
                  : EdgeInsets.all(32.h),
              separatorBuilder: (context, _) => const Divider(thickness: 0),
              itemBuilder: (context, index) {
                /* return the Item Overview Widget */
                return ItemOverview(
                  idx: index,
                  item: wares[index],
                  owner: user,
                );
              },
              itemCount: wares.length,
            ),
    );
  }
}
