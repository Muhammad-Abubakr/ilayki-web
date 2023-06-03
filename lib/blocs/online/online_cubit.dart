import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/user.dart';

part 'online_state.dart';

class OnlineCubit extends Cubit<OnlineState> {
  /* getting the firebase database singleton root ref */
  final database = FirebaseDatabase.instance.ref();

  OnlineCubit() : super(const OnlineInitial([]));
}
