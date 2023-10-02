part of 'items_bloc.dart';

enum Status {
  processing,
  rated,
  error,
}

abstract class ItemsState {
  final List<Item> items;
  final Status? status;

  const ItemsState({required this.items, this.status});
}

class ItemsInitial extends ItemsState {
  const ItemsInitial({required super.items, super.status});
}

class ItemsUpdated extends ItemsState {
  const ItemsUpdated({required super.items, super.status});
}
