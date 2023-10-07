part of 'requests_cubit.dart';

abstract class RequestsState {
  final List<Order>? requests;

  const RequestsState({this.requests});
}

class RequestsInit extends RequestsState {
  RequestsInit() : super(requests: List.empty(growable: true));
}

class RequestsPopulate extends RequestsState {
  const RequestsPopulate({required super.requests});
}
