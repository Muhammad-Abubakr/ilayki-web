part of 'products_bloc.dart';

abstract class ProductsEvent {}

class PostProduct extends ProductsEvent {
  final String name;
  final String price;
  final String stock;
  final Uint8List productImage;

  PostProduct({
    required this.name,
    required this.price,
    required this.stock,
    required this.productImage,
  });
}

class UpdateProduct extends ProductsEvent {
  final String? name;
  final String? price;
  final String? stock;
  final Uint8List? productImage;
  final Product product;

  UpdateProduct({
    required this.product,
    this.name,
    this.price,
    this.stock,
    this.productImage,
  });
}

class _Update extends ProductsEvent {
  final List<Product> products;

  _Update({required this.products});
}

class InitEvent extends ProductsEvent {}

class Dispose extends ProductsEvent {}
