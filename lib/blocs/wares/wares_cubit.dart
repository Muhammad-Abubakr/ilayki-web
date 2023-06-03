import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/models/item.dart';

part 'wares_state.dart';

class WaresCubit extends Cubit<WaresState> {
  /* Firebase Database instance */
  final _itemsRef = FirebaseDatabase.instance.ref("items");

  /* Streams Array */
  late StreamSubscription _itemsStream;

  /* Constructor */
  WaresCubit() : super(const WaresInitial(wares: []));

  // Initialize wares
  Future<void> intialize() async {
    // setting up a stream to firebase database ref items
    _itemsStream = _itemsRef.onValue.listen((event) {
      /* Container for wares */
      final List<Item> wareItems = List.empty(growable: true);

      // Getting the data from firebase
      var data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if we have some data
      if (data != null) {
        // filter the current user items
        for (var element in data.entries) {
          if (element.key != FirebaseAuth.instance.currentUser?.uid) {
            // Now we will get the data items for each user except the logged in
            final items = element.value as Map<dynamic, dynamic>;

            // iterating on each item and parsing it as Item
            for (var item in items.values) {
              final parsedItem = Item.fromJson(item.toString());

              // collecting the parsed item
              wareItems.add(parsedItem);
            }
          }
        }
      }

      /* and once we have iterated on all the users for all items they have */
      emit(WaresUpdated(wares: wareItems));
    });
  }

  /* Cancel Streams */
  void dispose() async {
    await _itemsStream.cancel();

    /* and clear state */
    emit(const WaresUpdated(wares: []));

    if (kDebugMode) {
      print("Ware Streams have been cancelled!");
    }
  }
}
