import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/product.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref('products');
  final Reference _imagesRef = FirebaseStorage.instance.ref('images');
  late StreamSubscription _userProductsStream;

  ProductsBloc() : super(ProductsInit()) {
    on<PostProduct>(_handlePostProduct);
    on<InitEvent>(_initializer);
    on<Dispose>(_disposer);
    on<_Update>(_populate);
  }

  FutureOr<void> _handlePostProduct(
      PostProduct event, Emitter<ProductsState> emit) async {
    try {
      emit(ProductsProcessing());
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userProductsRef = _productsRef.child(user.uid);
        final DatabaseReference newProductRef = userProductsRef.push();
        final Reference imageRef = _imagesRef.child(newProductRef.key!);

        final imageUrl = await (await imageRef.putData(event.productImage))
            .ref
            .getDownloadURL();

        final Product product = Product(
          pid: newProductRef.key!,
          ownerUid: user.uid,
          name: event.name,
          price: double.parse(event.price),
          quantity: int.parse(event.stock),
          productImage: imageUrl,
        );
        await newProductRef.set(product.toJson());
      }
    } on FirebaseException catch (e) {
      emit(ProductsError(error: e.message));
    } on FormatException catch (e) {
      emit(ProductsError(error: e.message));
    }
  }

  FutureOr<void> _initializer(InitEvent event, Emitter<ProductsState> emit) {
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          final userProductsRef = _productsRef.child(user.uid);
          _userProductsStream = userProductsRef.onValue.listen((event) {
            List<Product> products = List.empty(growable: true);
            DataSnapshot data = event.snapshot;
            if (data.value != null) {
              final parsed = data.value! as Map<dynamic, dynamic>;
              for (var product in parsed.values) {
                final Product modalProduct = Product.fromJson(product);
                products.add(modalProduct);
              }
            }
            add(_Update(products: products));
          });
        }
      });
    } on FirebaseException catch (e) {
      emit(ProductsError(error: e.message));
    }
  }

  FutureOr<void> _disposer(Dispose event, Emitter<ProductsState> emit) async {
    await _userProductsStream.cancel();
  }

  Product getProduct(String pid) {
    return state.products!.firstWhere((element) => element.pid == pid);
  }

  FutureOr<void> _populate(_Update event, Emitter<ProductsState> emit) {
    emit(ProductsPopulate(products: event.products));
  }
}
