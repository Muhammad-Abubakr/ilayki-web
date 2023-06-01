part of 'wares_bloc.dart';

abstract class WaresState extends Equatable {
  final List<Item> wares;

  const WaresState({required this.wares});

  @override
  List<Object> get props => [wares];
}

class WaresInitial extends WaresState {
  const WaresInitial({required super.wares});
}
