import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../models/order.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final DatabaseReference _requests = FirebaseDatabase.instance.ref('requests');
  late StreamSubscription _requestsStream;

  RequestsCubit() : super(RequestsInit());

  void initialize() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _requestsStream = _requests.onValue.listen((event) async {
          final List<Order> allRequests = List.empty(growable: true);
          final data = event.snapshot.value as Map<dynamic, dynamic>?;

          if (data != null) {
            for (var key in data.keys) {
              if (key == user.uid) {
                final requestsRef = _requests.child(key);
                final data =
                    (await requestsRef.get()).value as Map<dynamic, dynamic>?;

                if (data != null) {
                  for (var request in data.values) {
                    final parsedRequest = Order.fromJson(request.toString());
                    allRequests.add(parsedRequest);
                  }
                }
              }
            }
          }
          emit(RequestsPopulate(requests: allRequests));
        });
      }
    });
  }

  void dispose() async {
    await _requestsStream.cancel();
    emit(RequestsPopulate(requests: List.empty(growable: true)));
  }
}
