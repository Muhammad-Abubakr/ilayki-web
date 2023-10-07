import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/product.dart';

part 'wares_state.dart';

class WaresCubit extends Cubit<WaresState> {
  final _productsRef = FirebaseDatabase.instance.ref("products");
  late StreamSubscription _productsStream;

  WaresCubit() : super(WaresInit());

  Future<void> initialize() async {
    _productsStream = _productsRef.onValue.listen((event) {
      final List<Product> wares = List.empty(growable: true);
      var data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        for (var element in data.entries) {
          final products = element.value as Map<dynamic, dynamic>;

          for (var product in products.values) {
            final parsedProduct = Product.fromJson(product.toString());
            wares.add(parsedProduct);
          }
        }
      }

      emit(WaresPopulate(wares: wares));
    });
  }

  List<Product> getProductsForUser(String uid) {
    return state.wares!.where((element) => element.ownerUid == uid).toList();
  }

  Product getProduct(String pid) {
    return state.wares!.firstWhere((element) => element.pid == pid);
  }

  void dispose() async {
    await _productsStream.cancel();

    emit(WaresReset());
  }
}
