part of 'notifications_cubit.dart';

abstract class NotificationsState {
  final List<Order> notifications;

  const NotificationsState(this.notifications);
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial(super.notifications);
}

class NotificationsUpdate extends NotificationsState {
  const NotificationsUpdate(super.notifications);
}
