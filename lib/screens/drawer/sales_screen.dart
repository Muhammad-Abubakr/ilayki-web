import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/sales/sales_cubit.dart';

import '../../blocs/userbase/userbase_cubit.dart';
import '../../models/order.dart';
import '../chat/chat_room_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // userbase cubit
    final UserbaseCubit userbaseCubit = context.watch<UserbaseCubit>();

    // Sales Cubit
    final SalesCubit salesCubit = context.watch<SalesCubit>();
    final sales = salesCubit.state.sales;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sales),
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
                Text(AppLocalizations.of(context)!.sales),
                Text(AppLocalizations.of(context)!.status),
              ],
            ),
            const Divider(),

            /* Items */
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final buyer = userbaseCubit.getUser(sales[index].buyerID);

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
                          "currentUser": sales[index].sellerID,
                          "itemOwner": buyer,
                        }),
                        child: CircleAvatar(
                          backgroundImage:
                              Image.network(buyer.photoURL, fit: BoxFit.cover)
                                  .image,
                        ),
                      ),
                    ),

                    /* Buyer name */
                    title: Text("Ref#${sales[index].productId}",
                        textDirection: TextDirection.ltr),

                    /* Items description */
                    subtitle: Text(orderParser(context, sales[index])),

                    /* trailing button to accept order */
                    trailing: Text(
                        "Status: ${describeEnum(sales[index].status)}",
                        textAlign: TextAlign.center),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: sales.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // description parser
  String orderParser(BuildContext context, Order sale) {
    String order =
        '${AppLocalizations.of(context)!.price}: ${sale.totalPrice.toString()}\n';

    for (var orditem in sale.orderItems) {
      order = '$order${orditem.item.name} : ${orditem.quantity}\n';
    }

    return order;
  }
}
