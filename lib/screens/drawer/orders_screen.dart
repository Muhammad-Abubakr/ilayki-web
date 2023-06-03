import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/orders/orders_cubit.dart';

import '../../blocs/userbase/userbase_cubit.dart';
import '../../models/orderitem.dart';
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order"),
                Text("Status"),
              ],
            ),
            const Divider(),

            /* Items */
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final buyer = userbaseCubit.getUser(orders[index].buyerID);

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
                          "itemOwner": userbaseCubit.getUser(orders[index].sellerID),
                        }),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.sw),
                          child: Image.network(buyer.photoURL, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    /* Buyer name */
                    title: Text('Price: ${orders[index].totalPrice.toString()}'),

                    /* Items description */
                    subtitle: Text(orderParser(orders[index].orderItems)),

                    /* trailing button to accept order */
                    trailing: const Text("Completed", textAlign: TextAlign.center),
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
  String orderParser(List<OrderItem> items) {
    String order = 'Order:-\n';

    for (var orditem in items) {
      order = '$order${orditem.item.name} : ${orditem.quantity}\n';
    }

    return order;
  }
}
