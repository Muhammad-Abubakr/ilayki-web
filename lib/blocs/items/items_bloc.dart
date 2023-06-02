import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';

import '../../models/item.dart';

part 'items_event.dart';
part 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  // realtime database root reference
  final database = FirebaseDatabase.instance.ref();

  /* Subscription Point to the Item Stream */
  late StreamSubscription _itemsStream;

  ItemsBloc() : super(const ItemsInitial(items: [])) {
    /* Handlers */
    on<ActivateItemsListener>(_onActivatingItemsListeners);
    on<DeactivateItemsListener>(_onDeactivateItemsListener);
    on<ItemsDeleteEvent>(_onItemsDelete);
    on<_ItemsUpdateEvent>(_onItemsUpdate);
  }

  /* Initializating Items State */
  FutureOr<void> _onActivatingItemsListeners(
      ActivateItemsListener event, Emitter<ItemsState> emit) async {
    /* Attaching the Stream point */
    _itemsStream =
        database.child('items/${event.userBloc.state.user?.uid}').onValue.listen((event) {
      /* Obtaining the actual data from the Snapshot */
      final data = (event.snapshot.value as Map<dynamic, dynamic>?);

      /* Parsing the data if present*/
      if (data != null) {
        // declaring a list to hold the items data
        List<Item> userItems = [];

        for (var element in data.values) {
          /* Parsing and making new Items from data */
          final newItem = Item.fromJson(element.toString());

          // appending to the newly created list
          userItems.add(newItem);

          /* Once all items have been added, emit the state with updated items */
          add(_ItemsUpdateEvent(items: userItems));
        }
      }
    });
  }

  /* Unsubscribing from the items obervable stream */
  FutureOr<void> _onDeactivateItemsListener(
      DeactivateItemsListener event, Emitter<ItemsState> emit) {
    /* Unsubscribing to Items stream */
    _itemsStream.cancel().then((_) => print("Unsubscribed from items stream...!"));

    /* Clear the Items */
    emit(const ItemsUpdated(items: []));
  }

  /* deleting a specific object at some reference in firebase */
  FutureOr<void> _onItemsDelete(ItemsDeleteEvent event, Emitter<ItemsState> emit) async {
    // get the reference to the object
    final itemRef = database.child('items/${event.userUID}/${event.itemFID}');

    // remove
    await itemRef.remove();
  }

/* Used Internally to update Items got throught the stream subcription to firebase database*/
  FutureOr<void> _onItemsUpdate(_ItemsUpdateEvent event, Emitter<ItemsState> emit) {
    // emit the updated state
    emit(ItemsUpdated(items: event.items));
  }
}
