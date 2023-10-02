import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/notifications/notifications_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/models/order.dart';
import 'package:ilayki/models/user.dart';
import 'package:ilayki/screens/chat/chat_room_screen.dart';
import 'package:ilayki/services/firebase/auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late UserbaseCubit userbaseCubit;
  late NotificationsCubit notificationsCubit;
  late RequestsCubit requestsCubit;
  List<Order> notifications = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    userbaseCubit = context.watch<UserbaseCubit>();
    notificationsCubit = context.watch<NotificationsCubit>();
    requestsCubit = context.watch<RequestsCubit>();
    notifications = notificationsCubit.state.notifications;
    notifications.sort((a, b) => a.time.compareTo(b.time));
    notifications = notifications.reversed.toList();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return notifications.isEmpty
        ? Center(
            child: Text(AppLocalizations.of(context)!.allCaughtUp),
          )
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final buyer = userbaseCubit.getUser(notification.buyerID);
              final owner = userbaseCubit.getUser(notification.sellerID);

              return _buildRequestUpdateWidget(
                context,
                requestsCubit,
                buyer,
                owner,
                notification,
              );
            },
            itemCount: notifications.length,
          );
  }

  // description parser
  String orderParser(BuildContext context, Order request) {
    String order =
        '${AppLocalizations.of(context)!.price}: ${request.totalPrice.toString()}\n';

    for (var orderItem in request.orderItems) {
      order = '$order${orderItem.item.name} : ${orderItem.quantity}\n';
    }

    return order;
  }

  _buildRequestUpdateWidget(BuildContext context, RequestsCubit requestsCubit,
      User buyer, User owner, Order notification) {
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
            "currentUser": AuthService().currentUser!.uid,
            "itemOwner":
                buyer.uid == AuthService().currentUser!.uid ? owner : buyer,
          }),
          child: CircleAvatar(
            backgroundImage: Image.network(
                    buyer.uid == AuthService().currentUser!.uid
                        ? owner.photoURL
                        : buyer.photoURL,
                    fit: BoxFit.cover)
                .image,
          ),
        ),
      ),

      /* Buyer name */
      title: Text(
        "${notification.status == OrderStatus.pending ? "Request Sent" : notification.status == OrderStatus.denied ? "Request Denied" : notification.status == OrderStatus.completed ? "Order Completed" : "Request Accepted"} - Ref#${notification.productId}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      /* Items description */
      subtitle: Text(orderParser(context, notification)),

      /* trailing button to accept order */
      trailing: Text(
          "Status: ${describeEnum(notification.status)} \n ${notification.parsedTime} on ${notification.parsedDate}"),
    );
  }
}
