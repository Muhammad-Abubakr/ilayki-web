part of 'items_bloc.dart';

abstract class ItemsState {
  final List<Item> items;

  const ItemsState({required this.items});
}

class ItemsInitial extends ItemsState {
  const ItemsInitial({required super.items});
}

class ItemsUpdated extends ItemsState {
  const ItemsUpdated({required super.items});
}
