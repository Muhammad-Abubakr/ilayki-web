part of 'wares_cubit.dart';

abstract class WaresState {
  final List<Product>? wares;

  const WaresState({this.wares});
}

class WaresInit extends WaresState {
  WaresInit() : super(wares: List.empty(growable: true));
}

class WaresReset extends WaresState {
  WaresReset() : super(wares: List.empty(growable: true));
}

class WaresPopulate extends WaresState {
  const WaresPopulate({required super.wares});
}
