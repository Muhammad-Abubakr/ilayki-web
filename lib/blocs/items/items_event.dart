part of 'items_bloc.dart';

abstract class ItemsEvent {
  const ItemsEvent();
}

class _ItemsUpdateEvent extends ItemsEvent {
  final List<Item> items;

  const _ItemsUpdateEvent({required this.items});
}

class ItemsDeleteEvent extends ItemsEvent {
  final String userUID;
  final String itemFID;

  const ItemsDeleteEvent({required this.userUID, required this.itemFID});
}

class ActivateItemsListener extends ItemsEvent {
  final UserBloc userBloc;

  const ActivateItemsListener({required this.userBloc});
}

class DeactivateItemsListener extends ItemsEvent {
  const DeactivateItemsListener();
}
