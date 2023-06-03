part of 'requests_cubit.dart';

abstract class RequestsState {
  final List<Order> requests;

  const RequestsState(this.requests);
}

class RequestsInitial extends RequestsState {
  const RequestsInitial(super.requests);
}

class RequestsUpdate extends RequestsState {
  const RequestsUpdate(super.requests);
}
