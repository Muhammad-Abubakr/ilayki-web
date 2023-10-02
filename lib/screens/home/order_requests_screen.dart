import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../blocs/requests/requests_cubit.dart';
import '../../blocs/userbase/userbase_cubit.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../chat/chat_room_screen.dart';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  late UserbaseCubit userbaseCubit;
  late RequestsCubit requestsCubit;
  List<Order> requests = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    userbaseCubit = context.watch<UserbaseCubit>();
    requestsCubit = context.watch<RequestsCubit>();
    requests = requestsCubit.state.requests;
    requests.sort((a, b) => a.time.compareTo(b.time));
    requests = requests.reversed.toList();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return requests.isEmpty
        ? Center(
            child: Text(AppLocalizations.of(context)!.allCaughtUp),
          )
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final request = requests[index];
              final buyer = userbaseCubit.getUser(request.buyerID);

              return request.status == OrderStatus.pending
                  ? _buildAcceptanceOrDenialWidget(
                      context, requestsCubit, buyer, request)
                  : _buildOrderNotificationWidget(
                      context, requestsCubit, buyer, request);
            },
            itemCount: requests.length,
          );
  }
}

String orderParser(BuildContext context, Order request) {
  String order =
      '${AppLocalizations.of(context)!.price}: ${request.totalPrice.toString()}\n';

  for (var orderItem in request.orderItems) {
    order = '$order${orderItem.item.name} : ${orderItem.quantity}\n';
  }

  return order;
}

Widget _buildAcceptanceOrDenialWidget(
  BuildContext context,
  RequestsCubit requestsCubit,
  User buyer,
  Order request,
) {
  return ListTile(
    visualDensity: VisualDensity.comfortable,
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
          "currentUser": request.sellerID,
          "itemOwner": buyer,
        }),
        child: CircleAvatar(
          backgroundImage:
              Image.network(buyer.photoURL, fit: BoxFit.cover).image,
        ),
      ),
    ),

    /* Buyer name */
    title: Text(
      "Ref#${request.productId}",
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),

    /* Items description */
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(orderParser(context, request)),
        Text("${request.parsedTime} on ${request.parsedDate}"),
      ],
    ),

    /* trailing button to accept order */
    trailing: SizedBox(
      width: 0.25.sw,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => requestsCubit.decline(request),
            child: CircleAvatar(
              backgroundColor: Colors.redAccent.withOpacity(0.8),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => requestsCubit.accept(request),
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
}

_buildOrderNotificationWidget(BuildContext context, RequestsCubit requestsCubit,
    User buyer, Order request) {
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
          "currentUser": request.sellerID,
          "itemOwner": buyer,
        }),
        child: CircleAvatar(
          backgroundImage:
              Image.network(buyer.photoURL, fit: BoxFit.cover).image,
        ),
      ),
    ),

    /* Buyer name */
    title: Text(
      "Ref#${request.productId}",
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),

    /* Items description */
    subtitle: Text(orderParser(context, request)),

    /* trailing button to accept order */
    trailing: Text(
        "Status: ${describeEnum(request.status)} \n ${request.parsedTime} on ${request.parsedDate}"),
  );
}
