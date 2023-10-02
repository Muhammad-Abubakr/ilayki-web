import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/services/firebase/auth.dart';

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
    on<UpdateItemRating>(_onUpdateItemRating);
    on<ItemsDeleteEvent>(_onItemsDelete);
    on<_ItemsUpdateEvent>(_onItemsUpdate);
  }

  /* Initializating Items State */
  FutureOr<void> _onActivatingItemsListeners(
      ActivateItemsListener event, Emitter<ItemsState> emit) async {
    AuthService().subscribe.listen((user) {
      if (user != null) {
        /* Attaching the Stream point */
        _itemsStream =
            database.child('items/${user.uid}').onValue.listen((event) {
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
    });
  }

  /* Unsubscribing from the items obervable stream */
  FutureOr<void> _onDeactivateItemsListener(
      DeactivateItemsListener event, Emitter<ItemsState> emit) async {
    /* Unsubscribing to Items stream */
    await _itemsStream.cancel();

    if (kDebugMode) {
      print("Unsubscribed from items stream...!");
    }

    /* Clear the Items */
    emit(const ItemsUpdated(items: []));
  }

  /* deleting a specific object at some reference in firebase */
  FutureOr<void> _onItemsDelete(
      ItemsDeleteEvent event, Emitter<ItemsState> emit) async {
    // get the reference to the object
    final itemRef = database.child('items/${event.userUID}/${event.itemFID}');

    // remove
    await itemRef.remove();
  }

/* Used Internally to update Items got throught the stream subcription to firebase database*/
  FutureOr<void> _onItemsUpdate(
      _ItemsUpdateEvent event, Emitter<ItemsState> emit) {
    // emit the updated state
    emit(ItemsUpdated(items: event.items));
  }

  FutureOr<void> _onUpdateItemRating(
      UpdateItemRating event, Emitter<ItemsState> emit) async {
    // get the reference to the object
    final itemRef = database.child('items/${event.ownerUid}/${event.itemId}');

    //   get the item
    final snapshot = await itemRef.get();

    if (snapshot.value != null) {
      final item = Item.fromJson(snapshot.value.toString());
      final prevRating = item.rating;
      final prevRatingCount = item.ratingCount;

      final newRatingCount = prevRatingCount + 1;
      final newRating = prevRatingCount == 0
          ? event.rating
          : (((prevRatingCount * prevRating!) + event.rating) / newRatingCount)
              .toStringAsFixed(1);

      final updatedItem = item.copyWith(
        rating: double.parse(newRating.toString()),
        ratingCount: newRatingCount,
      );

      await itemRef.set(updatedItem.toJson());
    }
  }
}
