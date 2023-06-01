import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/item.dart';

part 'wares_event.dart';
part 'wares_state.dart';

class WaresBloc extends Bloc<WaresEvent, WaresState> {
  WaresBloc() : super(const WaresInitial(wares: [])) {
    /* Handlers */
    on<WaresEvent>((event, emit) {});
  }
}
