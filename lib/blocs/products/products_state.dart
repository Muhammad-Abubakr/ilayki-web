part of 'products_bloc.dart';

abstract class ProductsState {
  final List<Product>? products;
  final String? error;

  const ProductsState({this.products, this.error});
}

class ProductsInit extends ProductsState {}

class ProductsProcessing extends ProductsState {
  const ProductsProcessing({required super.products, required super.error});
}

class ProductsError extends ProductsState {
  const ProductsError({required super.error});
}

class ProductsPopulate extends ProductsState {
  const ProductsPopulate({required super.products});
}
