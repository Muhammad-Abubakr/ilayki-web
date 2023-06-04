import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/screens/chat/chat_room_screen.dart';

import '../../models/orderitem.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // userbase cubit
    final UserbaseCubit userbaseCubit = context.watch<UserbaseCubit>();

    // request cubit
    final RequestsCubit requestsCubit = context.watch<RequestsCubit>();
    final state = requestsCubit.state;

    return state.requests.isEmpty
        ? Center(
            child: Text(AppLocalizations.of(context)!.allCaughtUp),
          )
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final buyer = userbaseCubit.getUser(state.requests[index].buyerID);

              return ListTile(
                visualDensity: VisualDensity.adaptivePlatformDensity,
                /* Buyer Pfp */
                leading: Container(
                  margin: EdgeInsets.all(6.0.h),
                  padding: EdgeInsets.all(6.0.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.sw),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(ChatRoomScreen.routeName, arguments: {
                      "currentUser": state.requests[index].sellerID,
                      "itemOwner": userbaseCubit.getUser(state.requests[index].buyerID),
                    }),
                    child: CircleAvatar(
                      backgroundImage: Image.network(buyer.photoURL, fit: BoxFit.cover).image,
                    ),
                  ),
                ),

                /* Buyer name */
                title: Text('Price: ${state.requests[index].totalPrice.toString()}'),

                /* Items description */
                subtitle: Text(orderParser(state.requests[index].orderItems)),

                /* trailing button to accept order */
                trailing: SizedBox(
                  width: 0.25.sw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => requestsCubit.decline(state.requests[index]),
                        child: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => requestsCubit.accept(state.requests[index]),
                        child: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.8),
                          child: const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: state.requests.length,
          );
  }

  // description parser
  String orderParser(List<OrderItem> items) {
    String order = 'Order:-\n';

    for (var orditem in items) {
      order = '$order${orditem.item.name} : ${orditem.quantity}\n';
    }

    return order;
  }
}
