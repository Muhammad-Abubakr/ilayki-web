part of 'wares_cubit.dart';

abstract class WaresState extends Equatable {
  final List<Item> wares;

  const WaresState({required this.wares});

  @override
  List<Object> get props => [wares];
}

class WaresInitial extends WaresState {
  const WaresInitial({required super.wares});
}

class WaresUpdated extends WaresState {
  const WaresUpdated({required super.wares});
}
