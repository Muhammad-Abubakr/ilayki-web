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
  const ActivateItemsListener();
}

class UpdateItemRating extends ItemsEvent {
  final String ownerUid;
  final String itemId;
  final double rating;

  const UpdateItemRating(
      {required this.rating, required this.ownerUid, required this.itemId});
}

class DeactivateItemsListener extends ItemsEvent {
  const DeactivateItemsListener();
}
