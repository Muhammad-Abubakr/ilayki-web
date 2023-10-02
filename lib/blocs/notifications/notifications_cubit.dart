import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/models/order.dart';
import 'package:ilayki/services/firebase/auth.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  /* acquiring the database reference */
  final DatabaseReference _notifications =
      FirebaseDatabase.instance.ref('notifications');

  /* Streams Subscription */
  late StreamSubscription _stream;

  NotificationsCubit()
      : super(NotificationsInitial(List.empty(growable: true)));

  /* initialize */
  void initialize() {
    // get the requests that are only for the current user
    AuthService().subscribe.listen((user) {
      if (user != null) {
        // set this key as the ref to our requests
        final notificationsRef = _notifications.child(user.uid);

        _stream = notificationsRef.onValue.listen((event) async {
          /* container for requests */
          final List<Order> container = List.empty(growable: true);

          // get all the notifications for the user
          final data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            // for each notification in the notifications
            for (var notification in data.values) {
              // parse each notification to Order
              final parsedNotification =
                  Order.fromJson(notification.toString());

              // add to container
              container.add(parsedNotification);
            }
          }

          emit(NotificationsUpdate(container));
        });
      }
    });
  }

  void dispose() async {
    await _stream.cancel();

    // clearing the state
    emit(const NotificationsUpdate([]));

    if (kDebugMode) {
      print("Cancelling notifications stream...");
    }
  }
}
