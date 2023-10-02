import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/orders/orders_cubit.dart';
import 'package:ilayki/screens/home/order_rating_screen.dart';

import '../../blocs/userbase/userbase_cubit.dart';
import '../../models/order.dart';
import '../chat/chat_room_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // userbase cubit
    final UserbaseCubit userbaseCubit = context.watch<UserbaseCubit>();

    // Orders Cubit
    final OrdersCubit ordersCubit = context.watch<OrdersCubit>();
    final orders = ordersCubit.state.orders;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* Header */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.orders),
                Text(AppLocalizations.of(context)!.status),
              ],
            ),
            const Divider(),

            /* Items */
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final seller = userbaseCubit.getUser(orders[index].sellerID);
                  final isNotRated = orders[index]
                      .orderItems
                      .any((element) => element.item.rating == null);

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
                        onTap: () => Navigator.of(context)
                            .pushNamed(ChatRoomScreen.routeName, arguments: {
                          "currentUser": orders[index].buyerID,
                          "itemOwner":
                              userbaseCubit.getUser(orders[index].sellerID),
                        }),
                        child: CircleAvatar(
                          backgroundImage:
                              Image.network(seller.photoURL, fit: BoxFit.cover)
                                  .image,
                        ),
                      ),
                    ),

                    /* Buyer name */
                    title: Text("Ref#${orders[index].productId}"),

                    /* Items description */
                    subtitle: Text(orderParser(context, orders[index])),

                    /* trailing button to accept order */
                    trailing: orders[index].status != OrderStatus.denied
                        ? Column(
                            children: [
                              Text(
                                  "Status: ${describeEnum(orders[index].status)}",
                                  textAlign: TextAlign.center),
                              if (orders[index].status == OrderStatus.accepted)
                                InkWell(
                                  onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .confirmationDialog),
                                            content: const Text(
                                                "Only mark the order completed if you have received the item."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text("Cancel")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    ordersCubit.markCompleted(
                                                        orders[index]);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Confirm")),
                                            ],
                                          )),
                                  child: Card(
                                    elevation: 4,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 32.h),
                                      child: Text(
                                        "Mark as Completed",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.spMax),
                                      ),
                                    ),
                                  ),
                                ),
                              if (orders[index].status ==
                                      OrderStatus.completed &&
                                  isNotRated)
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => OrderRatingsScreen(
                                            owner: seller.uid,
                                            items: orders[index].orderItems)),
                                  ),
                                  child: Card(
                                    elevation: 4,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 32.h),
                                      child: Text(
                                        "Rate Order",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.spMax),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Text("Status: ${describeEnum(orders[index].status)}",
                            textAlign: TextAlign.center),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: orders.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // description parser
  String orderParser(BuildContext context, Order item) {
    String order =
        '${AppLocalizations.of(context)!.price}: ${item.totalPrice.toString()}\n';

    for (var orditem in item.orderItems) {
      order = '$order${orditem.item.name} : ${orditem.quantity}\n';
    }

    return order;
  }
}
